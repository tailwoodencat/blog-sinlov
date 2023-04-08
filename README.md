## repo info

[https://github.com/tailwoodencat/blog-sinlov](https://github.com/tailwoodencat/blog-sinlov)

## theme

more use see [https://github.com/dillonzq/LoveIt](https://github.com/dillonzq/LoveIt)


## CI

 - vercel [https://vercel.com/sinlov](https://vercel.com/sinlov)

## icon

- icon from [https://fontawesome.com/](https://fontawesome.com/)

```html
    {{- $bUrl := .URL | absLangURL -}}
    <link rel="icon" href="{{ $bUrl }}favicon.ico?v=2">
```

## usage

- install node.js

```bash
# windows
scoop install hugo

# macos
brew install hugo

# init
make init

# local debug
make debug

# build
make build
make buildRepo

# if tools error try make utils to install
make destination
```