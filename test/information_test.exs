defmodule LicensePlatePT.InformationTest do
  @moduledoc false

  @subject LicensePlatePT.Information

  use ExUnit.Case
  use ExUnitProperties

  doctest @subject

  alias LicensePlatePT.LicensePlate

  describe "distance_between" do
    test "Same type, same letters" do
      assert @subject.distance_between("AA-00-01", "AA-00-01") == 0
      assert @subject.distance_between("AA-00-01", "AA-00-02") == 1
      assert @subject.distance_between("AA-00-02", "AA-00-01") == 1

      assert @subject.distance_between("AA-00-01", "AA-99-99") == 9_998
    end

    test "Same type, different letters - Type 1" do
      assert @subject.distance_between("AA-00-01", "AB-00-01") == 10_000
      assert @subject.distance_between("AA-99-99", "AB-00-01") == 2
      assert @subject.distance_between("AB-00-01", "AA-99-99") == 2
    end

    test "Same type, different letters - Type 4" do
      assert @subject.distance_between("AB-15-AA", "AB-15-AB") == 100
      assert @subject.distance_between("AB-15-MP", "AB-89-MQ") == 174
      assert @subject.distance_between("AB-89-MQ", "AB-15-MP") == 174
    end

    test "Same type, edge case (K, W, Y) - Type 4" do
      assert @subject.distance_between("AV-99-ZZ", "AX-00-AA") == 1
    end

    test "Valid Type 2 license plates with K should return nil when letters are different" do
      refute @subject.distance_between("23-22-AK", "90-22-AL")
      refute @subject.distance_between("23-22-KA", "90-22-LL")
    end

    test "Valid Type 2 license plates with K should return distance when letters are the same" do
      assert @subject.distance_between("23-22-AK", "23-24-AK") == 2
      assert @subject.distance_between("23-22-KA", "23-22-KC") == 20_000
    end

    test "Different type" do
      assert @subject.distance_between("99-99-ZZ", "00-AA-01") == 2
      assert @subject.distance_between("99-ZZ-99", "AA-01-AA") == 2
      assert @subject.distance_between("AB-00-01", "AA-99-99") == 2
    end
  end

  describe "get_type" do
    test "Valid, full license plates" do
      assert @subject.get_type("AA-00-01") == [1]
      assert @subject.get_type("10-00-AA") == [2]
      assert @subject.get_type("03-AA-01") == [3]
      assert @subject.get_type("AA-03-AB") == [4]
    end

    test "Valid, single type partial license plates" do
      assert @subject.get_type("A_-_3-_1") == [1]
      assert @subject.get_type("1_-_3-_B") == [2]
      assert @subject.get_type("1_-B_-__") == [3]
      assert @subject.get_type("__-B_-__") == [3]
      assert @subject.get_type("9_-__-2_") == [3]
      assert @subject.get_type("A_-_3-_B") == [4]
    end

    test "Valid, multiple type partial license plates" do
      assert @subject.get_type("A_-_3-__") == [1, 4]
      assert @subject.get_type("__-__-33") == [1, 3]
      assert @subject.get_type("__-__-__") == [1, 2, 3, 4]
    end

    test "Invalid" do
      assert is_nil(@subject.get_type("AA-00-A1"))
      assert is_nil(@subject.get_type("10-00-32"))
      assert is_nil(@subject.get_type("03"))
      assert is_nil(@subject.get_type(nil))
    end

    property "Valid license plate should always return a type" do
      check all(license_plate <- license_plate_generator()) do
        refute is_nil(@subject.get_type(license_plate))
      end
    end
  end

  describe "get_possibilities" do
    test "Type 1" do
      assert @subject.get_possibilities("AB-51-25") == 1
      assert @subject.get_possibilities("AB-51-_5") == 10
      assert @subject.get_possibilities("AB-5_-_5") == 100
      assert @subject.get_possibilities("AB-__-5_") == 1000
    end

    test "Type 2" do
      assert @subject.get_possibilities("4_-__-AB") == 10 * 100
    end

    test "Type 1 and Type 4, only letters" do
      assert @subject.get_possibilities("AB-__-__") == 10_000 + 100 * 23 * 23
      assert @subject.get_possibilities("A_-__-__") == 10_000 * 23 + 100 * 23 * 23 * 23
    end

    test "Type 1 and Type 4, with letters and numbers" do
      assert @subject.get_possibilities("AB-4_-__") == 1000 + 10 * 23 * 23
      assert @subject.get_possibilities("A_-_5-__") == 1000 * 23 + 10 * 23 * 23 * 23
    end

    test "Type 2 and Type 4, only letters" do
      assert @subject.get_possibilities("__-__-AB") == 10_000 + 100 * 23 * 23
      assert @subject.get_possibilities("__-__-A_") == 10_000 * 23 + 100 * 23 * 23 * 23
    end

    test "Type 3, only letters" do
      assert @subject.get_possibilities("__-AB-__") == 10_000
      assert @subject.get_possibilities("__-A_-__") == 10_000 * 23
    end

    test "Type 4, only letters" do
      assert @subject.get_possibilities("AB-__-CD") == 100
      assert @subject.get_possibilities("AB-__-C_") == 100 * 23
    end

    test "Type 4, with letters and numbers" do
      assert @subject.get_possibilities("AB-1_-C_") == 10 * 23
    end
  end

  describe "letters_distance_to_beginning" do
    test "K should not be included in the cound" do
      assert @subject.letters_distance_to_beginning("AAAL") == 10
    end
  end

  # Format generator, this can generate invalid license plates
  defp license_plate_generator() do
    gen all(
          type <- StreamData.integer(1..4),
          letters <- StreamData.string([?A..?Z, ?A..?Z, ?A..?Z, ?A..?Z], length: 4),
          numbers <- StreamData.integer(0..9999)
        ) do
      if type in [1, 2, 3] do
        %LicensePlate{
          type: type,
          letters: String.slice(letters, 0, 2),
          numbers: numbers
        }
      else
        %LicensePlate{
          type: type,
          letters: letters,
          numbers: floor(numbers / 100)
        }
      end
      |> to_string()
    end
  end
end
