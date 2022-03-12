defmodule St7735.Utils do
  alias Circuits.SPI

  use Bitwise

  @typep send_response :: St7735.t() | {:error, binary()}

  @st7735_swreset 0x01
  @st7735_slpout 0x11
  @st7735_frmctr1 0xB1
  @st7735_frmctr2 0xB2
  @st7735_frmctr3 0xB3
  @st7735_ramwr 0x2C
  @st7735_invctr 0xB4
  @st7735_pwctr1 0xC0
  @st7735_pwctr2 0xC1
  @st7735_pwctr4 0xC3
  @st7735_pwctr5 0xC4
  @st7735_vmctr1 0xC5
  @st7735_invoff 0x20
  @st7735_invon 0x21
  @st7735_madctl 0x36
  @st7735_colmod 0x3A
  @st7735_caset 0x2A
  @st7735_raset 0x2B
  @st7735_gmctrp1 0xE0
  @st7735_gmctrn1 0xE1
  @st7735_noron 0x13
  @st7735_dispon 0x29

  ######################################################################################################################
  # Translation of Pimoroni's St7735-Python
  # https://github.com/pimoroni/st7735-python/blob/master/library/ST7735/__init__.py
  @spec open(St7735.t()) :: St7735.t()
  def open(st7735 \\ St7735.new()) do
    x1 = st7735.screen_width - 1 + st7735.offset_left
    y1 = st7735.screen_height - 1 + st7735.offset_top

    st7735
    |> init_spi()
    |> init_dc_gpio()
    |> init_backlight()
    |> command(@st7735_swreset)
    |> tap(fn _ -> :timer.sleep(150) end)
    |> command(@st7735_slpout)
    |> tap(fn _ -> :timer.sleep(500) end)
    |> command(@st7735_frmctr1)
    |> data(@st7735_swreset)
    |> data(@st7735_ramwr)
    |> data(0x2D)
    |> command(@st7735_frmctr2)
    |> data(@st7735_swreset)
    |> data(@st7735_ramwr)
    |> data(0x2D)
    |> command(@st7735_frmctr3)
    |> data(@st7735_swreset)
    |> data(@st7735_ramwr)
    |> data(0x2D)
    |> data(@st7735_swreset)
    |> data(@st7735_ramwr)
    |> data(0x2D)
    |> command(@st7735_invctr)
    |> data(0x07)
    |> command(@st7735_pwctr1)
    |> data(0xA2)
    |> data(0x02)
    |> data(0x84)
    |> command(@st7735_pwctr2)
    |> data(0x0A)
    |> data(0x00)
    |> command(@st7735_pwctr4)
    |> data(0x8A)
    |> data(0x2A)
    |> command(@st7735_pwctr5)
    |> data(0x8A)
    |> data(0xEE)
    |> command(@st7735_vmctr1)
    |> data(0x0E)
    |> then(&if &1.invert, do: command(&1, @st7735_invon), else: command(&1, @st7735_invoff))
    |> command(@st7735_madctl)
    |> data(0xC8)
    |> command(@st7735_colmod)
    |> data(0x05)
    |> command(@st7735_caset)
    |> data(0x00)
    |> then(&data(&1, &1.offset_left))
    |> data(0x00)
    |> then(&data(&1, &1.screen_width + &1.offset_left - 1))
    |> command(@st7735_raset)
    |> data(0x00)
    |> then(&data(&1, &1.offset_top))
    |> data(0x00)
    |> then(&data(&1, &1.screen_height + &1.offset_top - 1))
    |> command(@st7735_gmctrp1)
    |> data(0x02)
    |> data(0x1C)
    |> data(0x07)
    |> data(0x12)
    |> data(0x37)
    |> data(0x32)
    |> data(0x29)
    |> data(0x2D)
    |> data(0x29)
    |> data(0x25)
    |> data(0x2B)
    |> data(0x39)
    |> data(0x00)
    |> data(0x01)
    |> data(0x03)
    |> data(0x10)
    |> command(@st7735_gmctrn1)
    |> data(0x03)
    |> data(0x1D)
    |> data(0x07)
    |> data(0x06)
    |> data(0x2E)
    |> data(0x2C)
    |> data(0x29)
    |> data(0x2D)
    |> data(0x2E)
    |> data(0x2E)
    |> data(0x37)
    |> data(0x3F)
    |> data(0x00)
    |> data(0x00)
    |> data(0x02)
    |> data(0x10)
    |> command(@st7735_noron)
    |> tap(fn _ -> :timer.sleep(100) end)
    |> command(@st7735_dispon)
    |> tap(fn _ -> :timer.sleep(100) end)
    # Column addr set
    |> command(@st7735_caset)
    |> data(st7735.offset_left >>> 8)
    # XSTART
    |> data(st7735.offset_left)
    |> data(x1 >>> 8)
    # XEND
    |> data(x1)
    # Column addr set
    |> command(@st7735_raset)
    |> data(st7735.offset_top >>> 8)
    # YSTART
    |> data(st7735.offset_top)
    |> data(y1 >>> 8)
    # YEND
    |> data(y1)
    # write to RAM
    |> command(@st7735_ramwr)
  end

  ######################################################################################################################
  @doc """
  draw/2.

  img_data_fun should return return a list of rgb565 data, see PimoroniAutomationHatMini.img_data/2 for an example.

  """
  @spec draw(St7735.t(), function() | St7735.DisplayBehaviour.img_data()) :: send_response()
  def draw(st7735, get_img_data) when is_function(get_img_data),
    do: send(st7735, get_img_data.(), true, 4096)

  def draw(st7735, rg565_img_data) when is_list(rg565_img_data),
    do: send(st7735, rg565_img_data, true, 4096)

  ######################################################################################################################
  @spec init_spi(St7735.t()) :: St7735.t()
  defp init_spi(st7735) do
    {:ok, spi_ref} = SPI.open("spidev#{st7735.port}.#{st7735.cs}", speed_hz: st7735.speed_hz)
    %St7735{st7735 | spi_ref: spi_ref}
  end

  ######################################################################################################################
  @spec init_dc_gpio(St7735.t()) :: St7735.t()
  defp init_dc_gpio(st7735) do
    {:ok, dc_gpio_ref} = Circuits.GPIO.open(st7735.dc, :output)
    %St7735{st7735 | dc_gpio_ref: dc_gpio_ref}
  end

  ######################################################################################################################
  # Copied from Cocoa-Xu's ST7789-Elixir
  # https://github.com/cocoa-xu/st7789_elixir/blob/main/lib/st7789_elixir.ex#L436-L442
  @spec init_backlight(St7735.t()) :: St7735.t()
  defp init_backlight(%{backlight: backlight} = st7735) when backlight >= 0 do
    {:ok, backlight_gpio_ref} = Circuits.GPIO.open(backlight, :output)
    Circuits.GPIO.write(backlight_gpio_ref, 0)

    :timer.sleep(100)

    Circuits.GPIO.write(backlight_gpio_ref, 1)
    %St7735{st7735 | backlight_gpio_ref: backlight_gpio_ref}
  end

  ######################################################################################################################
  # Copied from Cocoa-Xu's ST7789-Elixir
  # https://github.com/cocoa-xu/st7789_elixir/blob/main/lib/st7789_elixir.ex#L252-L254
  @spec command(St7735.t(), integer()) :: send_response()
  defp command(display, data),
    do: send(display, data, false)

  ######################################################################################################################
  # Copied from Cocoa-Xu's ST7789-Elixir
  # https://github.com/cocoa-xu/st7789_elixir/blob/main/lib/st7789_elixir.ex#L265-L267
  @spec data(St7735.t(), integer()) :: send_response()
  defp data(display, data),
    do: send(display, data, true)

  ######################################################################################################################
  # Copied from Cocoa-Xu's ST7789-Elixir
  # https://github.com/cocoa-xu/st7789_elixir/blob/main/lib/st7789_elixir.ex#L316-L351
  @spec send(St7735.t(), integer(), boolean(), integer()) :: send_response()
  defp send(display, bytes, is_data, chunk_size \\ 4096)

  defp send(display = %St7735{}, bytes, true, chunk_size) do
    send(display, bytes, 1, chunk_size)
  end

  defp send(display = %St7735{}, bytes, false, chunk_size) do
    send(display, bytes, 0, chunk_size)
  end

  defp send(display = %St7735{}, bytes, is_data, chunk_size)
       when (is_data == 0 or is_data == 1) and is_integer(bytes) do
    send(display, [Bitwise.band(bytes, 0xFF)], is_data, chunk_size)
  end

  defp send(display = %St7735{}, bytes, is_data, chunk_size)
       when (is_data == 0 or is_data == 1) and is_list(bytes) do
    send(display, IO.iodata_to_binary(bytes), is_data, chunk_size)
  end

  @gpio_dc_error_msg "gpio[:dc] is nil"
  defp send(
         display = %St7735{dc_gpio_ref: dc_gpio_ref, spi_ref: spi_ref},
         bytes,
         is_data,
         chunk_size
       )
       when (is_data == 0 or is_data == 1) and is_binary(bytes) do
    if dc_gpio_ref != nil do
      Circuits.GPIO.write(dc_gpio_ref, is_data)

      for xfdata <- chunk_binary(bytes, chunk_size) do
        {:ok, _ret} = Circuits.SPI.transfer(spi_ref, xfdata)
      end

      display
    else
      {:error, @gpio_dc_error_msg}
    end
  end

  ######################################################################################################################
  # Copied from Cocoa-Xu's ST7789-Elixir
  # https://github.com/cocoa-xu/st7789_elixir/blob/main/lib/st7789_elixir.ex#L269-L292
  defp chunk_binary(binary, chunk_size) when is_binary(binary) do
    total_bytes = byte_size(binary)
    full_chunks = div(total_bytes, chunk_size)

    chunks =
      if full_chunks > 0 do
        for i <- 0..(full_chunks - 1), reduce: [] do
          acc -> [:binary.part(binary, chunk_size * i, chunk_size) | acc]
        end
      else
        []
      end

    remaining = rem(total_bytes, chunk_size)

    chunks =
      if remaining > 0 do
        [:binary.part(binary, chunk_size * full_chunks, remaining) | chunks]
      else
        chunks
      end

    Enum.reverse(chunks)
  end
end
