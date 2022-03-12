# St7735Elixir
Elixir Implementation for the [Pimoroni Automation Hat
Mini](https://shop.pimoroni.com/products/automation-hat-mini?variant=31478878077011) display

Copies code heavily from **Cocoa-Xu's** Elixir implementation of
[ST7789](https://github.com/cocoa-xu/st7789_elixir) as well as **Pimoroni's**
Python implementation of [ST7735](https://github.com/pimoroni/st7735-python).

The dependencies of this app don't play nicely with Mac OS (Big Sur), but
compiles fine on an Ubuntu 20.4 VM. There are many TODO's in order to make this
a more generic library for usage with ST7735 LCD displays as this was mostly an
experiment with working with Pimoroni's Automation Hat Mini.

Finally (and redundantly), this was developed using a Raspberry Pi 3 and
Pimoroni Automation Hat Mini and used within a Nerves application.


## Usage
### Get a background image (optional)
/priv in your host app is a good place to put it if you're using Nerves.

### Start the display
If using a background image, be sure to pass the filepath to it in new/1.

```
img_filepath = List.to_string(:code.priv_dir(:your_host_app_name) ++ '/analog-inputs-blank.jpg')

st7735 =
  St7735.new([img_filepath: img_filepath])
  |> St7735.Utils.open()

```

### Write rgb565 image data to display (pass a function or data)
```
data = [0.0, 12.0, 24.0] # You'll probably read this data from an ADC (analog to digital)
rgb565_img_data = St7735.Displays.PimoroniAutomationHatMini.img_data(st7735, data) end
St7735.Utils.draw(st7735, rgb565_img_data)

Or, pass a function

data = [0.0, 12.0, 24.0] # You'll probably read this data from an ADC (analog to digital)
img_data_fun = fn -> displaySt7735.Displays.PimoroniAutomationHatMini.img_data(st7735, data) end
St7735.Utils.draw(st7735, img_data_fun)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `st7735_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:st7735_elixir, github: "mattjg908/st7735_elixir", tag: "v0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/st7735_elixir](https://hexdocs.pm/st7735_elixir).

