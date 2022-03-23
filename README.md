# 複数環境向けのTerraformのCICD環境をCodebuildで構築

## 環境
以下の環境をterraformで管理していると仮定する
- develop：開発環境
- staging：試験環境
- main：本番環境

## Codebuildビルドプロジェクト
develop環境向け
- terraform-dev-dryrun  : dryrunプロジェクト
- terraform-dev         : releaseプロジェクト　　

staging環境向け
- terraform-stg-dryrun  : dryrunプロジェクト
- terraform-stg         : releaseプロジェクト　
　  
main環境向け  
- terraform-prd-dryrun  : dryrunプロジェクト
- terraform-prd         : releaseプロジェクト

## 今回構築するCICD
![Slide3](https://user-images.githubusercontent.com/85344890/159631744-31352b8d-ce93-4a48-987e-07593efb0441.jpg)


## Codebuild環境
<img width="1562" alt="image" src="https://user-images.githubusercontent.com/85344890/158951066-121eb740-e772-4a2e-b54c-5e07b3b0822c.png">

## Dryrunプロジェクトのwebhookアクション
### terraform-dev-dryrun
<img width="725" alt="image" src="https://user-images.githubusercontent.com/85344890/158950358-972850b3-b483-4184-97e4-6b8a8b425426.png">

### terraform-stg-dryrun 
<img width="727" alt="image" src="https://user-images.githubusercontent.com/85344890/158950544-1fd1baef-efd0-4ee3-a578-099f11640b47.png">

### terraform-prd-dryrun
<img width="726" alt="image" src="https://user-images.githubusercontent.com/85344890/158951479-ceb78bdd-cc73-4d32-93ad-7be5807f3137.png">



## ディレクトリ構造
<img width="212" alt="スクリーンショット 2022-03-18 14 39 14" src="https://user-images.githubusercontent.com/85344890/158946097-8c3e8d9c-fe79-415f-8879-081bc8ae67cb.png">

```
.
├── backend.tf
├── builder
│   ├── build.yml
│   └── dryrun.yml
├── config
│   ├── dev
│   │   ├── ap-northeast-1.backend
│   │   └── ap-northeast-1.tfvars
│   ├── prd
│   │   ├── ap-northeast-1.backend
│   │   └── ap-northeast-1.tfvars
│   └── stg
│       ├── ap-northeast-1.backend
│       └── ap-northeast-1.tfvars
├── iam_user.tf
├── locals.tf
├── provider.tf
└── variable.tf
```


## buildspec.yml
- [builder/dryrun.yml](https://github.com/jin-python-lc/terraform-codebuild/blob/main/builder/dryrun.yml) : dryrunプロジェクト用yml
- [builder/build.yml](https://github.com/jin-python-lc/terraform-codebuild/blob/main/builder/build.yml) : releaseプロジェクト用yml

```yml:builder/dryrun.yml
version: 0.2

phases:
  install:
    on-failure: ABORT | CONTINUE
    commands:
       - echo $CODEBUILD_INITIATOR
       - echo $CODEBUILD_BUILD_ID
       - echo $CODEBUILD_WEBHOOK_TRIGGER
       - echo $CODEBUILD_SOURCE_VERSION
       - export job_name=(${CODEBUILD_BUILD_ID//:/ })
       - export split_build_name=(${job_name//-/ })
       - export DEPLOY_ENV=${split_build_name[1]}
       - export TFVARS_PATH=./config/${DEPLOY_ENV}/ap-northeast-1.tfvars
       - wget -q https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_amd64.zip
       - unzip terraform_0.14.9_linux_amd64.zip
       - mv terraform /bin
       - terraform init -backend-config=./config/${DEPLOY_ENV}/ap-northeast-1.backend -no-color
  pre_build:
    on-failure: ABORT | CONTINUE
    commands:
       - echo pre_build phases
       - terraform plan ${DESTROY_MODE} -var-file=${TFVARS_PATH} -no-color
```

```yml:builder/build.yml
version: 0.2

phases:
  install:
    on-failure: ABORT | CONTINUE
    commands:
       - echo $CODEBUILD_INITIATOR
       - echo $CODEBUILD_BUILD_ID
       - echo $CODEBUILD_WEBHOOK_TRIGGER
       - echo $CODEBUILD_SOURCE_VERSION
       - export job_name=(${CODEBUILD_BUILD_ID//:/ })
       - export split_build_name=(${job_name//-/ })
       - export DEPLOY_ENV=${split_build_name[1]}
       - export TFVARS_PATH=./config/${DEPLOY_ENV}/ap-northeast-1.tfvars
       - wget -q https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_amd64.zip
       - unzip terraform_0.14.9_linux_amd64.zip
       - mv terraform /bin
       - terraform init -backend-config=./config/${DEPLOY_ENV}/ap-northeast-1.backend -no-color
  pre_build:
    on-failure: ABORT | CONTINUE
    commands:
       - echo pre_build phases
       - terraform plan ${DESTROY_MODE} -var-file=${TFVARS_PATH} -no-color -out plan.out
  build:
    on-failure: ABORT | CONTINUE
    commands:
       - echo build phases
       - terraform apply plan.out
```

## terraform
バージョンとtfstate置き場
```tf:backend.tf
terraform {
  required_version = "~> 0.14.9"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.74.1"
    }
  }

  backend "s3" {
  }
}
```
```backend:ap-northeast-1.backend
bucket = "terraform-codebuild-tfstate"
key = "terraform/develop/ap-northeast-1.tfstate"
region = "ap-northeast-1"
```

terraform実行権限はcodebuildのロールで管理  
マルチアカウントで環境を分ける場合はassumeroleを使用

```tf:provider.tf
provider "aws" {
    region = "ap-northeast-1"
    #assume_role {
    #    role_arn = "arn:aws:iam::${var.aws.account_id}:role/StsAdminRole"
    #}
}
```

試しに作成するもの
```tf:variable.tf
variable "aws" { type = map(any) }
variable "stage" { type = map(any) }
variable "project" { type = map(any) }
variable "iam_users" { type = map(any) }
```
```tf:iam_user.tf
resource "aws_iam_user" "iam_user" {
    for_each = var.iam_users
    name = "${each.value.name}-${var.stage.short_name}"
    path = "/"
    tags = merge(local.tags, map("Name", "${local.system_name}-user"))
}
```
```tf:locals.tf
locals {
  system_name = "${var.project.name}-${var.stage.short_name}"
  tags = {
      Env = var.stage.name
      Project = var.project.name
  }
}
```
tfvars
develop用
```tfvars:config/dev/ap-northeast-1.tfvars
aws = {
    account_id = "064944057077"
}

stage = {
    name = "develop"
    short_name = "dev"
}

project = {
    name = "terraform-codebuild"
}

iam_users = {
    test1 = {
        key = "test1"
        name = "test1@terraform"
    }
    test2 = {
        key = "test2"
        name = "test2@terraform"
    }
    test3 = {
        key = "test3"
        name = "test3@terraform"
    }
}
```
staging用
```tfvars:config/stg/ap-northeast-1.tfvars
aws = {
    account_id = "064944057077"
}

stage = {
    name = "staging"
    short_name = "stg"
}

project = {
    name = "terraform-codebuild"
}

iam_users = {
    test1 = {
        key = "test1"
        name = "test1@terraform"
    }
    test2 = {
        key = "test2"
        name = "test2@terraform"
    }
    test3 = {
        key = "test3"
        name = "test3@terraform"
    }
}
```
production用
```tfvars:config/prd/ap-northeast-1.tfvars
aws = {
    account_id = "064944057077"
}

stage = {
    name = "production"
    short_name = "prd"
}

project = {
    name = "terraform-codebuild"
}

iam_users = {
    #(for_each)
    #     = each.value
    test1 = {
        #   = each.value.key
        key = "test1"
        #   = each.value.name
        name = "test1@terraform"
    }
    test2 = {
        key = "test2"
        name = "test2@terraform"
    }
    test3 = {
        key = "test3"
        name = "test3@terraform"
    }
}
```

以下も可
```tf:iam_user.tf
resource "aws_iam_user" "iam_user" {
    for_each = var.iam_users
    name = "${each.value}-${var.stage.short_name}"
    path = "/"
    tags = merge(local.tags, map("Name", "${local.system_name}-user"))
}
```
```tfvars:config/*/ap-northeast-1.tfvars
.
.
.
iam_users = {
    #(for_each)
    #each.key = each.value  
    name1 = "test1@terraform"
    name2 = "test2@terraform"
    name3 = "test3@terraform"
}
```

## 課題
Codebuildは任意の場所で処理を停止するような分岐を設けることができない(?)ため、
（sourceコマンドで外部シェルスクリプトを利用することはできるのでシェルで書けばできそうだが可読性が落ちてしまう）
terraform planで異常に気付けても強制的にビルトを停止するしか無い点。
Jenkinsなら簡単に分岐を書けるため、その点ではJenkinsの方が優れている。
