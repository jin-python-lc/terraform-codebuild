terraform-codebuild

## 環境
- develop
- staging
- main

## Codebuildビルドプロジェクト
- terraform-dev-dryrun  : develop環境向けdryrunプロジェクト
- terraform-dev         : develop環境向けreleaseプロジェクト
- terraform-stg-dryrun  : staging環境向けdryrunプロジェクト
- terraform-stg         : staging環境向けreleaseプロジェクト     
- terraform-prd-dryrun  : main環境向けdryrunプロジェクト
- terraform-prd         : main環境向けreleaseプロジェクト

## buildspec.yml
- [builder/build/buildspec.yml](https://github.com/jin-python-lc/terraform-codebuild/blob/main/builder/build/buildspec.yml) : releaseプロジェクト用yml
- [builder/dryrun/buildspec.yml](https://github.com/jin-python-lc/terraform-codebuild/blob/main/builder/dryrun/buildspec.yml) : releaseプロジェクト用yml
