defmodule LicensePlatePTTest do
  @moduledoc false

  use ExUnit.Case
  @subject LicensePlatePT
  doctest @subject

  alias LicensePlatePT.LicensePlate

  describe "Extract - Valid license plates" do
    test "With hiffen, upper case" do
      license_plate = @subject.extract("Message 09-XH-33")
      assert license_plate == "09-XH-33"
    end

    test "With hiffen, lower case" do
      license_plate = @subject.extract("09-xh-33")
      assert license_plate == "09-XH-33"
    end

    test "Without hiffen, upper case" do
      license_plate = @subject.extract("09XH33", without_hiffen: true)
      assert license_plate == "09-XH-33"
    end

    test "Without hiffen, lower case" do
      license_plate = @subject.extract("09xh33", without_hiffen: true)
      assert license_plate == "09-XH-33"
    end

    test "Without hiffen, can extract hiffen license plate" do
      license_plate = @subject.extract("09-XH-33", without_hiffen: true)
      assert license_plate == "09-XH-33"
    end

    test "With hiffen, upper case, exact_text: true" do
      license_plate = @subject.extract("09-XH-33", exact_text: true)
      assert license_plate == "09-XH-33"
    end

    test "With hiffen and message, upper case, exact_text: true" do
      license_plate = @subject.extract("Message 09-XH-33", exact_text: true)
      assert is_nil(license_plate)
    end

    test "Without hiffen and message, lower case, exact_text: true, without_hiffen: true" do
      assert "09-XH-33" ==
               @subject.extract("09xh33", exact_text: true, without_hiffen: true)
    end

    test "Invalid input, nil" do
      license_plate = @subject.extract(nil)
      assert is_nil(license_plate)
    end
  end

  describe "Extract - Valid match license plates" do
    test "With hiffen, partial plate - match: true" do
      license_plate = @subject.extract("09-xh-__", match: true)
      assert license_plate == "09-XH-__"
    end

    test "With hiffen, partial plate with text - match: true" do
      license_plate = @subject.extract("09-xh-__ bmw", match: true)
      assert license_plate == "09-XH-__"
    end

    test "Without hiffen, partial plate - without_hiffen: true, match: true" do
      license_plate = @subject.extract("09xh__", without_hiffen: true, match: true)
      assert license_plate == "09-XH-__"
    end

    test "With hiffen, partial plate - without_hiffen: true, match: true" do
      license_plate = @subject.extract("09-xh-__", without_hiffen: true, match: true)
      assert license_plate == "09-XH-__"
    end

    test "Using ?, With hiffen, partial plate - match: true" do
      license_plate = @subject.extract("09-xh-??", match: true)
      assert license_plate == "09-XH-??"
    end

    test "Using *, With hiffen, partial plate - match: true" do
      license_plate = @subject.extract("09-xh-**", match: true)
      assert license_plate == "09-XH-**"
    end
  end

  describe "Extract - Invalid license plates" do
    test "With hiffen, upper case in middle of the text" do
      license_plate = @subject.extract("A matrícula A9-XH-33 pertecente ao meu veículo")

      assert is_nil(license_plate)
    end
  end

  describe "to_string" do
    test "Type 1" do
      assert "AA0011" == to_string(%LicensePlate{type: 1, letters: "AA", numbers: 11})
    end

    test "Type 2" do
      assert "0001AA" == to_string(%LicensePlate{type: 2, letters: "AA", numbers: 1})
      assert "0011AA" == to_string(%LicensePlate{type: 2, letters: "AA", numbers: 11})
      assert "0111AA" == to_string(%LicensePlate{type: 2, letters: "AA", numbers: 111})
      assert "1111AA" == to_string(%LicensePlate{type: 2, letters: "AA", numbers: 1111})
    end

    test "Type 3" do
      assert "00AA01" == to_string(%LicensePlate{type: 3, letters: "AA", numbers: 1})
      assert "00AA11" == to_string(%LicensePlate{type: 3, letters: "AA", numbers: 11})
      assert "01AA11" == to_string(%LicensePlate{type: 3, letters: "AA", numbers: 111})
      assert "11AA11" == to_string(%LicensePlate{type: 3, letters: "AA", numbers: 1111})
    end

    test "Type 4" do
      assert "AA01AA" == to_string(%LicensePlate{type: 4, letters: "AAAA", numbers: 1})
      assert "AA11AA" == to_string(%LicensePlate{type: 4, letters: "AAAA", numbers: 11})
      assert "AB00AA" == to_string(%LicensePlate{type: 4, letters: "ABAA", numbers: 0})
    end

    test "Type 2 - Dashed" do
      assert "00-01-AA" ==
               to_string(%LicensePlate{type: 2, letters: "AA", numbers: 1, dashes: true})

      assert "00-11-AA" ==
               to_string(%LicensePlate{type: 2, letters: "AA", numbers: 11, dashes: true})
    end
  end

  describe "to_struct!" do
    test "License plate without dash" do
      %LicensePlate{
        type: 1,
        letters: "AA",
        numbers: 11
      } = @subject.to_struct!("AA0011")

      %LicensePlate{
        type: 2,
        letters: "AA",
        numbers: 11
      } = @subject.to_struct!("0011AA")

      %LicensePlate{
        type: 3,
        letters: "AA",
        numbers: 11
      } = @subject.to_struct!("00AA11")

      %LicensePlate{
        type: 4,
        letters: "AAAA",
        numbers: 1
      } = @subject.to_struct!("AA01AA")
    end

    test "License plate with dash" do
      %LicensePlate{
        type: 1,
        letters: "AA",
        numbers: 11
      } = @subject.to_struct!("AA-00-11")

      %LicensePlate{
        type: 2,
        letters: "AA",
        numbers: 11
      } = @subject.to_struct!("00-11-AA")

      %LicensePlate{
        type: 3,
        letters: "AA",
        numbers: 11
      } = @subject.to_struct!("00-AA-11")

      %LicensePlate{
        type: 4,
        letters: "AAAA",
        numbers: 1
      } = @subject.to_struct!("AA-01-AA")
    end
  end

  describe "to_struct" do
    test "Valid license plate" do
      {:ok,
       %LicensePlate{
         type: 1,
         letters: "AA",
         numbers: 11
       }} = @subject.to_struct("AA0011")
    end

    test "Valid license plate in lowercase" do
      {:ok,
       %LicensePlate{
         type: 1,
         letters: "AA",
         numbers: 11
       }} = @subject.to_struct("Aa0011")
    end

    test "Invalid license plate" do
      assert_raise ArgumentError, "Invalid license plate: AA001", fn ->
        @subject.to_struct!("AA001")
      end
    end
  end
end
