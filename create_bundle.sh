#!/bin/sh

BUNDLE="KITAssetsPickerController/KITAssetsPickerController.bundle"

rm -rf $BUNDLE
mkdir $BUNDLE

find "KITAssetsPickerController/Resources" -name "*.png" | xargs -I {} cp {} "$BUNDLE/"
find "KITAssetsPickerController/Resources" -name "*.lproj" | xargs -I {} cp -R {} "$BUNDLE/"
echo "Created $BUNDLE"
