#!/bin/sh

swiftgen xcassets --templatePath "templates/xcassets.stencil" --param enumName=GLAssets --output "../project/Global/XCAssets.swift" ../project/Resources/Assets.xcassets
