defmodule LicensePlatePT do
  @moduledoc """
  Utilify functions for portuguese license plates.

  Support the following formats:
  * AA-00-00
  * 00-00-AA
  * 00-AA-00
  * AA-00-AA
  """

  alias LicensePlatePT.LicensePlate

  require Logger

  @letter_lower_limit ?A
  @letter_upper_limit ?Z

  @type123_max_number 9999
  @type4_max_number 99

  def get_letter_lower_limit(), do: @letter_lower_limit
  def get_letter_upper_limit(), do: @letter_upper_limit

  def get_type123_max_number(), do: @type123_max_number
  def get_type4_max_number(), do: @type4_max_number

  # This should only be used for extracting license plate in text
  @license_plate_regex ~r/([A-Z][A-Z]\-[0-9][0-9]\-[0-9][0-9])|([0-9][0-9]\-[0-9][0-9]\-[A-Z][A-Z])|([0-9][0-9]\-[A-Z][A-Z]\-[0-9][0-9])|([A-Z][A-Z]\-[0-9][0-9]\-[A-Z][A-Z])/

  # This should be used for full license plate validation
  @license_plate_without_hiffen_regex ~r/((?!AM|AP|CC|EM|MB|MC|ME|MF|MG|MH|MI|MJ|ML|MU|MV|MX|MZ|NU|NV|NZ|OU|OV|OZ|PR|PU|PV|PZ|QU|QV|QZ|RU|RV|RZ|SU|SV|SZ|TB|TC|TD|TE|TF|TG|TH|TJ|TL|TQ|TZ|UM|UN|UO|UP|UQ|UR|US|UT|UV|VM|VN|VO|VP|VQ|VR|VS|VT|ZA|ZC|ZD|ZG|ZH|ZI|ZJ|ZL|ZM|ZM|ZQ|ZT|ZU|ZV)[A-JL-VXZ][A-JL-VXZ](?!0000)[0-9][0-9][0-9][0-9])|((?!0000)[0-9][0-9][0-9][0-9](?!AS|CU|OO)([A-JL-VXZ][A-JL-VXZ]|AK|KA|KB|KC|KD|KE|KF))|((?!00[A-JL-VXZ][A-JL-VXZ]00)[0-9][0-9](?!AM|AN|AR|AP|CU|HO|ME|MG|MX|OO)[A-JL-VXZ][A-JL-VXZ][0-9][0-9])|(?!AA00AA)AA\d\d(AA|EE|II|OO|UU)|(?!AM|AP|([AEIOU][AEIOU]\d\d[A-Z][AEIOU]|[A-Z][AEIOU]\d\d[AEIOU][AEIOU])|(AN\d\dAL)|([B-DF-HJ-NP-TV-Z][AEIOU]\d\d[B-DF-HJ-NP-TV-Z][AEIOU]))([A-JL-VXZ][A-JL-VXZ][0-9][0-9][A-JL-VXZ][A-JL-VXZ])/

  # This should be used for partial plate match (dash is mandatory)
  @license_plate_partial_regex ~r/([A-Z\_\?\*][A-Z\_\?\*]\-[0-9\_\?\*][0-9\_\?\*]\-[0-9\_\?\*][0-9\_\?\*])|([0-9\_\?\*][0-9\_\?\*]\-[0-9\_\?\*][0-9\_\?\*]\-[A-Z\_\?\*][A-Z\_\?\*])|([0-9\_\?\*][0-9\_\?\*]\-[A-Z\_\?\*][A-Z\_\?\*]\-[0-9\_\?\*][0-9\_\?\*])|([A-Z\_\?\*][A-Z\_\?\*]\-[0-9\_\?\*][0-9\_\?\*]\-[A-Z\_\?\*][A-Z\_\?\*])/
  @license_plate_partial_without_hiffen_regex ~r/([A-Z\_\?\*][A-Z\_\?\*][0-9\_\?\*][0-9\_\?\*][0-9\_\?\*][0-9\_\?\*])|([0-9\_\?\*][0-9\_\?\*][0-9\_\?\*][0-9\_\?\*][A-Z\_\?\*][A-Z\_\?\*])|([0-9\_\?\*][0-9\_\?\*][A-Z\_\?\*][A-Z\_\?\*][0-9\_\?\*][0-9\_\?\*])|([A-Z\_\?\*][A-Z\_\?\*][0-9\_\?\*][0-9\_\?\*][A-Z\_\?\*][A-Z\_\?\*])/

  # Used to extract information from full license plate
  @extractor_regex ~r/^((?<letters1>[A-Z][A-Z])(?<numbers1>[0-9][0-9][0-9][0-9]))|((?<numbers2>[0-9][0-9][0-9][0-9])(?<letters2>[A-Z][A-Z]))|((?<numbers3_1>[0-9][0-9])(?<letters3>[A-Z][A-Z])(?<numbers3_2>[0-9][0-9]))|((?<letters4_1>[A-Z][A-Z])(?<numbers4>[0-9][0-9])(?<letters4_2>[A-Z][A-Z]))$/

  def get_regex(), do: @license_plate_regex
  def license_plate_without_hiffen_regex(), do: @license_plate_without_hiffen_regex

  def license_plate_partial_without_hiffen_regex(),
    do: @license_plate_partial_without_hiffen_regex

  defdelegate valid?(license_plate, opts \\ []), to: LicensePlatePT.Validation

  defdelegate valid_partial?(license_plate, opts \\ []),
    to: LicensePlatePT.Validation

  defdelegate after_then!(license_plate1, license_plate2), to: LicensePlatePT.Validation

  defdelegate before_then!(license_plate1, license_plate2),
    to: LicensePlatePT.Validation

  defdelegate fill_partial(partial_license_plate), to: LicensePlatePT.Manipulation

  defdelegate add_dash(license_plate), to: LicensePlatePT.Manipulation

  defdelegate get_middle_between(license_plate1, license_plate2),
    to: LicensePlatePT.Manipulation

  defdelegate next(license_plate, increment \\ 1), to: LicensePlatePT.Manipulation
  defdelegate previous(license_plate, increment \\ 1), to: LicensePlatePT.Manipulation
  defdelegate next_letters(letters), to: LicensePlatePT.Manipulation
  defdelegate previous_letters(letters), to: LicensePlatePT.Manipulation

  defdelegate get_type(license_plate), to: LicensePlatePT.Information

  defdelegate distance_between(license_plate1, license_plate2),
    to: LicensePlatePT.Information

  defdelegate split(license_plate), to: LicensePlatePT.Manipulation

  def to_struct(requested_license_plate) when is_binary(requested_license_plate) do
    license_plate =
      requested_license_plate
      |> String.upcase()
      |> String.replace("-", "")

    has_dashes = String.contains?(requested_license_plate, "-")

    case valid?(license_plate) do
      true ->
        {type, letters, numbers} =
          @extractor_regex
          |> Regex.named_captures(license_plate)
          |> filter_empty()
          |> case do
            nil ->
              Logger.error("Invalid license plate: #{license_plate}")
              nil

            %{"letters1" => letters, "numbers1" => numbers} ->
              {1, letters, String.to_integer(numbers)}

            %{"letters2" => letters, "numbers2" => numbers} ->
              {2, letters, String.to_integer(numbers)}

            %{"letters3" => letters, "numbers3_1" => numbers1, "numbers3_2" => numbers2} ->
              {3, letters, String.to_integer("#{numbers1}#{numbers2}")}

            %{"letters4_1" => letters1, "letters4_2" => letters2, "numbers4" => numbers} ->
              {4, "#{letters1}#{letters2}", String.to_integer(numbers)}
          end

        {:ok,
         %LicensePlate{
           type: type,
           letters: letters,
           numbers: numbers,
           dashes: has_dashes
         }}

      false ->
        {:error, requested_license_plate}
    end
  end

  def to_struct!(license_plate) when is_binary(license_plate) do
    case to_struct(license_plate) do
      {:ok, output} ->
        output

      {:error, license_plate} ->
        raise ArgumentError, message: "Invalid license plate: #{license_plate}"
    end
  end

  defp filter_empty(nil), do: nil

  defp filter_empty(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      if value == "" do
        acc
      else
        acc
        |> Map.put(key, value)
      end
    end)
  end

  @doc """
  Extract a license plate, given a equal license plate, or a valid without hiffen license plate.

  This will always return a dashed license plate.

  ## Options
  * `:match` - Allow partial license plate to be extract. Default `false`.
  * `:without_hiffen` - Allow license plate to be extracted without hiffen. Defaults `false`.
  * `:exact_text` - Only return a license plate if it is the only text in the message sent by
    the user. Default `false`.
  """
  def extract(text, opts \\ [])

  def extract(text, opts) when is_binary(text) do
    text = String.upcase(text)
    exact_text = Keyword.get(opts, :exact_text, false)

    license_plate = extract_inner(text, opts)

    if exact_text == false || (exact_text == true && license_plate == text) do
      add_dash(license_plate)
    else
      nil
    end
  end

  def extract(_, _), do: nil

  defp extract_inner(text, opts) do
    match = Keyword.get(opts, :match, false)
    without_hiffen = Keyword.get(opts, :without_hiffen, false)

    regex =
      case match do
        true -> @license_plate_partial_regex
        false -> @license_plate_regex
      end

    license_plate = Regex.run(regex, String.upcase(text))

    license_plate_without_hiffen =
      case without_hiffen do
        true ->
          case match do
            true -> Regex.run(@license_plate_partial_without_hiffen_regex, String.upcase(text))
            false -> Regex.run(@license_plate_without_hiffen_regex, String.upcase(text))
          end

        false ->
          nil
      end

    choose_license_plate(license_plate, license_plate_without_hiffen)
  end

  defp choose_license_plate(license_plate, _) when not is_nil(license_plate),
    do: Enum.at(license_plate, 0)

  defp choose_license_plate(_, without_hiffen) when not is_nil(without_hiffen),
    do: Enum.at(without_hiffen, 0)

  defp choose_license_plate(_, _), do: nil
end
