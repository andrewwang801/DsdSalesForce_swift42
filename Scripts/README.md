# Scripts Code Generation

Scripts below use swiftgen to generate colors, images & view controllers for storyboards.

    - storyboard.sh
    - colors.sh
    - images.sh
    - strings.sh

We are using custom templates files (in *templates* directory) as SwiftGen changes templates when they update to new version and it really made me annoying. :disappointed:

To avoid bunch of code updating when of swiftgen version changes, decided to use own template file.

**Also Nested Types in extensions didn't allow me to use  Whole Module Optimization (A super cool  performance option introduced in Xcode 7.0) in release builds and it was the main reason that I decided to use custom template stencil files.**
    
    
