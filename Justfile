default:
    @just --list

make-tf-module:
    mise exec -- boilerplate \
        --template-url "infra/.boilerplate/blueprints/tf-module/" \
        --output-folder "infra/modules/" \
        --missing-config-action ignore \
        --disable-dependency-prompt
