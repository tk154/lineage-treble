#!/bin/bash

set -e

update_my_repo() {
    local repo="$1"
    local branch="$2"
    local upstream_url="$3"

    cd "$repo"
    git checkout "$branch"

    git remote | grep -q "upstream" || \
        git remote add upstream "$upstream_url"

    git fetch upstream
    git rebase upstream/"$branch"
    git push --force-with-lease

    echo ""
    cd ..
}

update_my_repos() {
    update_my_repo "lineage_build_unified" "lineage-$version-td" \
        "https://github.com/AndyCGYan/lineage_build_unified.git"

    update_my_repo "lineage_patches_unified" "lineage-$version-td" \
        "https://github.com/AndyCGYan/lineage_patches_unified.git"

    update_my_repo "vendor_hardware_overlay" "pie" \
        "https://github.com/TrebleDroid/vendor_hardware_overlay.git"
}

init_lineage_repo() {
    mkdir lineage$version
    cd lineage$version

    repo init -u https://github.com/LineageOS/android.git -b lineage-$version.0 --git-lfs
    cd ..
}

build_lineage() {
    cd lineage$version

    export USE_CCACHE=1
    export CCACHE_EXEC=/usr/bin/ccache
    export CCACHE_DIR=ccache

    bash lineage_build_unified/buildbot_unified.sh treble 64VN $build_args
    cp out/target/product/tdgsi_arm64_ab/system.img ../lineage$version.img

    cd ..
}

version="$1"
build_args="$2"

if [ -z "$version" ]; then
    echo "Missing LineageOS version"
    exit 1
fi

update_my_repos
[ -d "lineage$version" ] || init_lineage_repo
build_lineage

#cd sas-creator
#git pull
#sudo bash lite-adapter.sh 64 ../lineage$1/out/target/product/tdgsi_arm64_ab/system.img
#mv -f s.img ../lineage$1.img

#cd ..
#adb push lineage$1.img /sdcard/Download
