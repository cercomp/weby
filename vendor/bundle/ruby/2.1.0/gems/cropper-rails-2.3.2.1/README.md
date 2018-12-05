# Cropper::Rails

[Jquery Cropper](https://github.com/fengyuanchen/cropper) for Rails assets pipeline.

## Installation

This gem packs [cropper](https://github.com/fengyuanchen/cropper) (jquery version) and makes it available for rails assets pipeline. Add this gem and jquery-rails to your application's Gemfile:

```ruby
gem 'jquery-rails'
gem 'cropper-rails'
```

And then run `bundle install`.

Next add jquery and cropper to your assets:

`app/assets/javascripts/application.js`

```javascript
//= require jquery
//= require cropper
```

`app/assets/javascripts/application.css`

```css
/*
 *= require jquery
 *= require cropper
 */
```

## Usage

Read more about usage [here](https://github.com/fengyuanchen/cropper#getting-started)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
