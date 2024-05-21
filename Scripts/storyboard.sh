#!/bin/sh

swiftgen storyboards --templatePath "templates/storyboards.stencil" --param sceneEnumName=BHStoryboard --param segueEnumName=BHStoryboardSegue --output "../project/Global/Storyboard.swift" ../project/