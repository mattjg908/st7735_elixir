defmodule St7735 do
  @st7735_cols 132
  @st7735_rows 162

  @st7735_tftwidth 80
  @st7735_tftheight 160

  defstruct spi_ref: nil,
            dc_gpio_ref: nil,
            backlight_gpio_ref: nil,
            port: 0,
            # https://github.com/pimoroni/st7735-python/blob/master/library/ST7735/__init__.py#L32
            cs: 1,
            dc: 9,
            backlight: 25,
            rotation: 270,
            speed_hz: 4_000_000,
            colour: [255, 181, 86],
            text_x: 110,
            text_y: 34,
            bar_x: 25,
            bar_y: 37,
            bar_height: 8,
            bar_width: 73,
            # Value to increment for spacing text and bars vertically.
            offset: 14,
            # https://github.com/pimoroni/st7735-python/blob/master/library/ST7735/__init__.py#L160
            # https://github.com/pimoroni/st7735-python/blob/master/library/ST7735/__init__.py#L37
            offset_left: div(@st7735_cols - @st7735_tftwidth, 2),
            offset_top: div(@st7735_rows - @st7735_tftheight, 2),
            invert: true,
            screen_width: @st7735_tftwidth,
            screen_height: @st7735_tftheight,
            img_filepath: ""

  @type t :: %__MODULE__{
          spi_ref: reference() | nil,
          dc_gpio_ref: reference() | nil,
          backlight_gpio_ref: reference() | nil,
          port: integer(),
          cs: binary(),
          dc: integer(),
          backlight: integer(),
          rotation: integer(),
          speed_hz: integer(),
          colour: {integer(), integer(), integer()},
          text_x: integer(),
          text_y: integer(),
          bar_x: integer(),
          bar_y: integer(),
          bar_height: integer(),
          bar_width: integer(),
          offset: integer(),
          offset_left: number(),
          offset_top: number(),
          invert: boolean(),
          screen_width: number(),
          screen_height: number(),
          img_filepath: binary()
        }

  @doc """
  new/1.

  ## Examples

      iex> St7735.new(%{offset: 3})
      %St7735{offset: 3}

  """
  @spec new(map() | keyword()) :: %St7735{}
  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end
end
