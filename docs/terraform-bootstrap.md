# Terraform state backend bootstrap

## Purpose

Terraform needs its S3 backend bucket to exist before it can use that bucket.
We resolve this dependency by creating the bucket with a separate bootstrap
configuration using local state, then migrating that state to S3.

Bootstrap and application infrastructure can live in the same Git repository.
They run from separate Terraform root directories and have separate state files:

```text
infra/bootstrap/          -> bootstrap/terraform.tfstate in S3
infra/environments/dev/   -> dev/terraform.tfstate in S3 (planned)
```

Destroying the development stack does not manage or delete the bootstrap bucket.
The bucket also has a Terraform `prevent_destroy` guard. Retiring the backend
requires a separate, deliberate process after its state files are no longer needed.

## Configuration, plan, and state are different

| File | Purpose | Commit to Git? |
| --- | --- | --- |
| `*.tf` | Describes desired infrastructure and backend configuration | Yes |
| `*.tfplan` | Saves proposed actions for a subsequent apply | No |
| `*.tfstate` | Records resources managed by Terraform and their attributes | No |
| `.terraform.lock.hcl` | Records selected provider versions and checksums | Yes |

A saved plan is not a state file. Applying a plan creates or changes resources
and updates state. State and plan files can contain sensitive values.

## Sequence used in this project

Run these commands from the repository root. They work in PowerShell and Bash;
quoted arguments also avoid the argument parsing issue encountered in PowerShell.
This is a record of the bootstrap process, not a sequence to repeat after migration.

### 1. Define the bootstrap resources

The files under `infra/bootstrap/` declare the AWS provider and an S3 bucket with:

- A generated, globally unique name.
- Versioning for state recovery.
- S3-managed server-side encryption.
- Public access blocking.
- A bucket policy denying requests without HTTPS.
- A `prevent_destroy` lifecycle guard.

Initially there is no S3 backend block, so Terraform uses local state.

### 2. Initialize and check configuration

```text
terraform "-chdir=infra/bootstrap" init
terraform "-chdir=infra/bootstrap" fmt
terraform "-chdir=infra/bootstrap" validate
```

Initialization installs providers; it does not create the AWS resources.

### 3. Preview and apply the bootstrap changes

```text
terraform "-chdir=infra/bootstrap" plan "-out=bootstrap.tfplan"
terraform "-chdir=infra/bootstrap" apply "bootstrap.tfplan"
```

Review the plan before applying it. Applying a saved plan does not ask for an
additional confirmation. The initial apply created five resources: the bucket,
versioning configuration, encryption configuration, public access block, and policy.

Terraform recorded them locally in `infra/bootstrap/terraform.tfstate`.
The saved plan is also inside `infra/bootstrap/` because of `-chdir`.

### 4. Configure the new S3 backend

After the bucket exists, add `infra/bootstrap/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "inventory-tfstate-872ff07c7a6a1293f4af104c18"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

The bucket name above is the actual output from this project's initial apply.
A fresh bootstrap in another account will generate a different name.
Backend configuration must use that existing bucket's name.

`use_lockfile` enables native S3 locking for cooperating Terraform operations.
This is separate from S3 Object Lock; no DynamoDB table is required here.

### 5. Migrate the existing local state

Keep the local state files until migration has succeeded. Run:

```text
terraform "-chdir=infra/bootstrap" init -migrate-state
```

When Terraform asks to copy existing state to the new backend, enter `yes`.
This copies state to S3; it does not recreate the bucket or other resources.
Do not substitute `-reconfigure`: that option does not migrate existing state.

After migration, S3 is the active state location for future bootstrap operations.
Local backup files may remain; keep them out of Git and protect them as sensitive data.

### 6. Verify migration before continuing

```text
terraform "-chdir=infra/bootstrap" state list
terraform "-chdir=infra/bootstrap" plan
```

Confirm that Terraform still lists the five bootstrap resources and proposes no
infrastructure changes. Also confirm the state object exists in S3:

```text
aws s3api head-object --bucket inventory-tfstate-872ff07c7a6a1293f4af104c18 --key bootstrap/terraform.tfstate --region us-east-1
```

## Progress when this guide was written

- Bootstrap configuration validated and reviewed.
- Initial apply succeeded: five resources added.
- S3 backend configuration added.
- State migration to S3 completed successfully.
- Verification passed: `state list` showed all five resources, `plan` reported
  no changes, and `head-object` confirmed the state object exists in S3.
- The development infrastructure root has not yet been implemented.

## References

- [HashiCorp: S3 backend configuration and permissions](https://developer.hashicorp.com/terraform/language/backend/s3)
- [HashiCorp: initialization and state migration](https://developer.hashicorp.com/terraform/cli/commands/init)
- [AWS: Terraform backend best practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/backend.html)
