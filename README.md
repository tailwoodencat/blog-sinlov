## repo info

[https://github.com/tailwoodencat/blog-sinlov](https://github.com/tailwoodencat/blog-sinlov)

## theme

> WARN: DoIt 支持的最老的 Hugo 版本为 0.134.0

now theme [https://github.com/HEIGE-PCloud/DoIt](https://github.com/HEIGE-PCloud/DoIt)
config file [https://hugodoit.pages.dev/zh-cn/theme-documentation-basics/#site-configuration](https://hugodoit.pages.dev/zh-cn/theme-documentation-basics/#site-configuration)

### old theme

- LoveIt [https://github.com/dillonzq/LoveIt](https://github.com/dillonzq/LoveIt)


## CI

 - vercel [https://vercel.com/sinlov](https://vercel.com/sinlov)

## icon

- icon from [https://fontawesome.com/](https://fontawesome.com/)

```html
    {{- $bUrl := .URL | absLangURL -}}
    <link rel="icon" href="{{ $bUrl }}favicon.ico?v=2">
```

## usage

- install [make](https://www.gnu.org/software/make/)
- install [node.js](https://nodejs.org/)

```bash
### install hugo
## windows
# fix css/style.scss build error
scoop install hugo-extended
# with out Sass/SCSS
scoop install hugo
## macos
brew install hugo
## linux
sudo apt install hugo
sudo dnf install hugo
sudo pacman install hugo


# init to check once
make init

# local debug
make debug

# build
make build
make buildRepo

# if tools error try make utils to install
make destination
```