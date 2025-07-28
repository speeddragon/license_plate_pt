defmodule LicensePlatePT.LicensePlate do
  @moduledoc """
  Structrure for portuguese license plate.
  """

  @type t() :: %__MODULE__{
          type: integer(),
          letters: binary(),
          numbers: integer(),
          dashes: boolean()
        }

  defstruct [:type, :letters, :numbers, :dashes]

  defimpl String.Chars do
    def to_string(%LicensePlatePT.LicensePlate{
          type: type,
          letters: letters,
          numbers: numbers,
          dashes: dashes
        })
        when dashes in [nil, false] do
      numbers_string =
        numbers
        |> Integer.to_string()
        |> String.pad_leading(4, "0")

      case type do
        1 ->
          "#{letters}#{numbers_string}"

        2 ->
          "#{numbers_string}#{letters}"

        3 ->
          # Split numbers
          <<numbers1::binary-size(2), numbers2::binary-size(2)>> = numbers_string

          "#{numbers1}#{letters}#{numbers2}"

        4 ->
          # Split letters
          <<letters1::binary-size(2), letters2::binary-size(2)>> = letters

          numbers_string =
            numbers
            |> Integer.to_string()
            |> String.pad_leading(2, "0")

          "#{letters1}#{numbers_string}#{letters2}"
      end
    end

    def to_string(%LicensePlatePT.LicensePlate{
          type: type,
          letters: letters,
          numbers: numbers,
          dashes: true
        }) do
      numbers_string =
        numbers
        |> Integer.to_string()
        |> String.pad_leading(4, "0")

      case type do
        1 ->
          "#{letters}-#{numbers_string}"

        2 ->
          "#{numbers_string}-#{letters}"

        3 ->
          # Split numbers
          <<numbers1::binary-size(2), numbers2::binary-size(2)>> = numbers_string

          "#{numbers1}-#{letters}-#{numbers2}"

        4 ->
          # Split letters
          <<letters1::binary-size(2), letters2::binary-size(2)>> = letters

          numbers_string =
            numbers
            |> Integer.to_string()
            |> String.pad_leading(2, "0")

          "#{letters1}-#{numbers_string}-#{letters2}"
      end
    end
  end
end
