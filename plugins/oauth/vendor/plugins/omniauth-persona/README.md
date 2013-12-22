# OmniAuth Persona

This is a fork of https://github.com/intridea/omniauth-browserid, by
Michael Bleigh

Mozilla's [Persona](https://persona.org/) is a great implementation of
verified email that lets you quickly and easily login to websites. This
is an OmniAuth strategy that allows you to use Persona in your application!

## Installation

    gem install omniauth-persona

## Usage

Persona works using a Javascript-driven popup window. As such, there is
a little more work than usual to integrate Persona seamlessly into your
app. That being said, a default implementation of Persona will work as outlined below.

### Basic Case

To use the built-in form in order to authenticate with Persona, you simply need to add the strategy to your application:

```ruby
use OmniAuth::Builder do
  provider :persona
end
```

Now all you need to do is redirect your users to `/auth/persona` and you're all set!

### Better Integration

To better integrate Persona with your application, you will want to use
the Persona javascript directly in your app. Assuming you included the middleware as described above, here is a way you could structure your HTML:

```html
<html>
  <head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js" type="text/javascript"></script>
    <script src="https://login.persona.org/include.js" type="text/javascript"></script>
    <script type='text/javascript'>
      function loginViaEmail() {
        navigator.id.get(function(assertion) {
          if (assertion) {
            $('input[name=assertion]').val(assertion);
            $('form').submit();
          } else {
            window.location = "#{failure_path}"
          }
        });  
      }

      $(function() {
        $('button').click(function() {
          loginViaEmail();
          return false;
        });
      });
    </script>
  </head>
  <body>
    <form id='persona_form' action='/auth/persona/callback'>
      <input type='hidden' name='assertion'/>
      <button type='submit'>Login with Persona</button>
    </form>
  </body>
</html>
```

What this does is sets up a form with a "Login with Persona" button.
When the button of the form is clicked, it is intercepted by jQuery and
the Persona flow is started. Persona returns an `assertion` that is then
used to verify an email. In this example, the form points to
`/auth/persona/callback` which will automatically perform verification as well as return a standard OmniAuth hash.

## Options

These are the options you can specify that are relevant to Omniauth
Persona:

* `:verify_url` - The verifier URL (defaults to `https://login.persona.org/verify`)
* `:name` - The URL at which the strategy will be available (defaults to `persona`)
* `:audience_url` - The host of your site. Defaults to the `full_host` of OmniAuth (either automatically determined or determined by the `OmniAuth.config.full_host` option)

## License

Copyright (c) 2011 Michael Bleigh and Intridea, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
