#!/bin/sh

swiftgen strings --templatePath "templates/mystrings.stencil" --param enumName=L10n --output "../DSD Salesforce/Global/StringsAdded.swift" ../en.lproj/LiteralAdded.strings
