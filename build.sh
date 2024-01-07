#!/usr/bin/env bash
arch=("x86_64")

ROOT_DIR="$PWD"
REPO_DIR="$ROOT_DIR/$arch"
REPO_NAME="goonarch"
BUILD_DIR="$ROOT_DIR/build"


if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi


if [ ! -f /sbin/repoctl ]; then
    echo "repoctl not found, installing"
    git clone https://aur.archlinux.org/repoctl.git $BUILD_DIR/repoctl
    cd $BUILD_DIR/repoctl
    makepkg -si --noconfirm
    cd $ROOT_DIR
    rm -rf $BUILD_DIR/repoctl
fi


PKGS=$(/bin/cat pkgs.txt)

cd $BUILD_DIR
echo "Building packages"
sudo echo "Got sudo"
for pkg in $PKGS; do
    if [ -d $pkg ]; then
	cd ./$pkg
	git pull --rebase
    else
	git clone https://aur.archlinux.org/$pkg.git
	cd $pkg
    fi

    PKGDEST="$REPO_DIR" makepkg --config $ROOT_DIR/makepkg.conf -s --noconfirm
    cd $BUILD_DIR
done

cd $ROOT_DIR
echo "Updating Repo Database"
cd $REPO_DIR
repoctl add *.pkg.tar.xz

rm $REPO_NAME.db $REPO_NAME.files
cp $REPO_NAME.db.tar.zst $REPO_NAME.db
cp $REPO_NAME.files.tar.zst $REPO_NAME.files

if [ "$1" == "sign" ]; then
	echo "Signing the repo"
	repoctl sign
fi

if [ "$1" == "push" ]; then
    echo "Pushing the changes to the main repo"

    if [ "$CI" == "true" ]; then
        git config --global user.name "GitHub Actions"
        git config --global user.email "actions@github.com"
    fi

    git add *
    git commit -m "Updated Package List"
    git push
fi
