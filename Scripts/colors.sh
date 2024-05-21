#!/bin/sh

swiftgen colors --templatePath "templates/colors.stencil" --param enumName=MTColor --output "../project/Global/Colors.swift" ../project/Resources/Colors.xcassets
