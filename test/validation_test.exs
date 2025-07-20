defmodule LicensePlatePT.ValidationTest do
  @moduledoc false

  @subject LicensePlatePT.Validation
  use ExUnit.Case
  doctest @subject

  alias LicensePlatePT.LicensePlate

  describe "Check if pattern license plate is valid" do
    test "Valid values input" do
      assert @subject.valid_partial?("AA-__-__")
      assert @subject.valid_partial?("AA-3_-__")
      assert @subject.valid_partial?("AA-32-__")
      assert @subject.valid_partial?("AA-32-1_")
      assert @subject.valid_partial?("AA-32-10")

      assert @subject.valid_partial?("__-__-AA")
      assert @subject.valid_partial?("01-23-AA")

      assert @subject.valid_partial?("__-AA-__")

      assert @subject.valid_partial?("AA-__-AA")
    end

    test "Special case to not display type 4 license plate" do
      assert @subject.valid_partial?("??-??-AB")
    end

    test "Special case to only display type 4 license plate" do
      assert @subject.valid_partial?("**-**-AB")
    end

    test "Invalid cases" do
      refute @subject.valid_partial?("RS123")
    end

    test "Allow Invalid Type 4" do
      # We allow to not complicate validation on partial, proper validation 
      # should be done on complete license plate.
      assert @subject.valid_partial?("BA-__-AA")
    end
  end

  describe "valid?" do
    test "Invalid structure input" do
      # Invalid type
      refute @subject.valid?(%LicensePlate{type: 5, letters: "AA", numbers: 1})

      # Invalid letters
      refute @subject.valid?(%LicensePlate{type: 3, letters: "AAA", numbers: 1})
      refute @subject.valid?(%LicensePlate{type: 4, letters: "AA", numbers: 5})

      # Invalid numbers
      refute @subject.valid?(%LicensePlate{type: 3, letters: "AA", numbers: 342_423_432})
      refute @subject.valid?(%LicensePlate{type: 4, letters: "AAAA", numbers: 0})
    end

    test "Valid Type 1" do
      assert @subject.valid?("AA-01-23")
    end

    test "Valid Type 2 - K license plates" do
      # Support imported license plates with K (AK, KA, KB, KC, KD, KE , KF)
      assert @subject.valid?("00-01-AK")
      assert @subject.valid?("00-01-KA")
      assert @subject.valid?("00-01-KB")
      assert @subject.valid?("00-01-KC")
      assert @subject.valid?("00-01-KD")
      assert @subject.valid?("00-01-KE")
      assert @subject.valid?("00-01-KF")
    end

    test "Valid Type 3" do
      # Support new license plate type
      assert @subject.valid?("01-AA-33")
      assert @subject.valid?("99-ZZ-44")
    end

    test "Valid Type 4" do
      # Support new license plate type
      assert @subject.valid?("AA-01-AA")
      assert @subject.valid?("BB-33-EE")
      assert @subject.valid?("AX-33-AA")
    end

    test "Invalid text input" do
      assert @subject.valid?(nil) == false

      # Pattern type isn't a valid license plate
      assert @subject.valid?("AA-01-2_") == false
      assert @subject.valid?("AA-AA-AA") == false

      # All zeroes isn't a valid license plate
      assert @subject.valid?("AA-00-00") == false
      assert @subject.valid?("00-BA-00") == false

      # English alphabet not valid 
      assert @subject.valid?("AY-00-01") == false
      assert @subject.valid?("01-BW-00") == false
      assert @subject.valid?("00-34-BK") == false

      # Do not support K, W, Y in the new type
      refute @subject.valid?("YK-01-WA")

      # Special cases
      refute @subject.valid?("00-34-OO")

      refute @subject.valid?("00-001-FA")
    end

    test "Invalid Type 3" do
      refute @subject.valid?("03-AP-33")
    end

    test "Invalid Type 4" do
      # Special case
      refute @subject.valid?("AA-00-AA")
      refute @subject.valid?("AM-34-SS")
      refute @subject.valid?("AP-34-SS")
      refute @subject.valid?("AN-69-AL")
      refute @subject.valid?("BI-88-GO")
      refute @subject.valid?("BI-88-JE")
    end

    test "Invalid Type 4 - 4 Vowels" do
      # 4 vowels 
      refute @subject.valid?("AE-93-AE")
    end

    test "Invalid Type 4 - 3 Vowels" do
      # 3 vowels
      refute @subject.valid?("BA-93-UU")
      refute @subject.valid?("BE-93-EE")
      refute @subject.valid?("BI-93-AA")
      refute @subject.valid?("BI-99-OI")
      refute @subject.valid?("AA-00-DU")
    end

    test "Invalid Type 4 - 1 Vowels ending each letter group" do
      # 1 vowel in each letter group
      refute @subject.valid?("BA-33-CA")
      refute @subject.valid?("AE-93-CI")
      refute @subject.valid?("BA-44-DA")
      refute @subject.valid?("BA-44-DE")
      refute @subject.valid?("BA-44-DI")
      refute @subject.valid?("BA-44-DO")
      refute @subject.valid?("BA-44-DU")
      refute @subject.valid?("BE-44-DU")
    end

    test "Valid Type 4 - Vowels (Doesn't apply to AA)" do
      assert @subject.valid?("AA-31-AA")
      assert @subject.valid?("AA-31-EE")
      assert @subject.valid?("AA-31-II")
      assert @subject.valid?("AA-31-OO")
      assert @subject.valid?("AA-31-UU")
    end

    test "Valid Type 4 - 2 vowels, oneat start another at the end shoud be valid" do
      assert @subject.valid?("AB-33-DE")
    end

    test "Option - dashed: true - Valid" do
      assert @subject.valid?("90-23-DD", dashed: true)
    end

    test "Option - dashed: true - Invalid" do
      assert @subject.valid?("9023DD", dashed: true) == false
    end

    test "Option - stripped: true - Valid" do
      assert @subject.valid?("9023DD", stripped: true)
    end

    test "Option - stripped: true - Invalid" do
      assert @subject.valid?("90-23-DD", stripped: true) == false
    end

    test "Option - dashed: true, stripped: true" do
      assert_raise ArgumentError, fn ->
        @subject.valid?("90-23-DD", dashed: true, stripped: true)
      end
    end
  end

  describe "before_then!" do
    test "valid" do
      assert @subject.before_then!("AA-00-01", "AA-00-02")
      assert @subject.before_then!("AA-00-02", "00-AA-01")
      assert !@subject.before_then!("00-02-CC", "00-01-CB")
    end

    test "invalid" do
      assert !@subject.before_then!(nil, "AA-00-02")

      assert_raise(ArgumentError, fn ->
        @subject.before_then!("AA-000-01", "AA-00-02")
      end)
    end
  end

  describe "after_then!" do
    test "valid" do
      assert @subject.after_then!("AA-00-02", "AA-00-01")
      assert @subject.after_then!("00-AA-01", "AA-00-02")
      assert !@subject.after_then!("00-AA-01", "00-AA-02")
    end

    test "invalid" do
      assert !@subject.before_then!(nil, "AA-00-02")

      assert_raise(ArgumentError, fn ->
        @subject.before_then!("AA-000-01", "AA-00-02")
      end)
    end
  end
end
