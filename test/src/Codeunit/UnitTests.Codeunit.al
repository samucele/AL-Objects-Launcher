namespace SamueleCelebron.ObjectLauncher;

using System.Reflection;
using System.TestLibraries.Utilities;

codeunit 50110 "Obj. Launcher Unit Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryAssert: Codeunit "Library Assert";

    #region TableDataManager Tests

    [Test]
    procedure Initialize_SetsCorrectDefaults_ReadOnlyModeTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange & Act
        TableDataManager.Initialize(18, CompanyName);

        // Assert
        LibraryAssert.IsTrue(TableDataManager.GetReadOnlyMode(), 'ReadOnlyMode should be true after Initialize');
    end;

    [Test]
    procedure Initialize_SetsCorrectDefaults_ValidateFieldsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange & Act
        TableDataManager.Initialize(18, CompanyName);

        // Assert
        LibraryAssert.IsTrue(TableDataManager.GetValidateFields(), 'ValidateFields should be true after Initialize');
    end;

    [Test]
    procedure Initialize_SetsCorrectDefaults_RunTriggersTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange & Act
        TableDataManager.Initialize(18, CompanyName);

        // Assert
        LibraryAssert.IsTrue(TableDataManager.GetRunTriggers(), 'RunTriggers should be true after Initialize');
    end;

    [Test]
    procedure SetTableNumber_GetTableNumber_ReturnsCorrectValue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        ExpectedTableNumber: Integer;
    begin
        // Arrange
        ExpectedTableNumber := 18; // Customer table
        TableDataManager.Initialize(0, CompanyName);

        // Act
        TableDataManager.SetTableNumber(ExpectedTableNumber);

        // Assert
        LibraryAssert.AreEqual(ExpectedTableNumber, TableDataManager.GetTableNumber(), 'GetTableNumber should return the set table number');
    end;

    [Test]
    procedure SetCompanyName_GetCompanyName_ReturnsCorrectValue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        ExpectedCompanyName: Text;
    begin
        // Arrange
        ExpectedCompanyName := 'TEST_COMPANY';
        TableDataManager.Initialize(18, '');

        // Act
        TableDataManager.SetCompanyName(ExpectedCompanyName);

        // Assert
        LibraryAssert.AreEqual(ExpectedCompanyName, TableDataManager.GetCompanyName(), 'GetCompanyName should return the set company name');
    end;

    [Test]
    procedure SetValidateFields_GetValidateFields_ReturnsCorrectValue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act
        TableDataManager.SetValidateFields(false);

        // Assert
        LibraryAssert.IsFalse(TableDataManager.GetValidateFields(), 'GetValidateFields should return false after setting to false');
    end;

    [Test]
    procedure SetRunTriggers_GetRunTriggers_ReturnsCorrectValue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act
        TableDataManager.SetRunTriggers(false);

        // Assert
        LibraryAssert.IsFalse(TableDataManager.GetRunTriggers(), 'GetRunTriggers should return false after setting to false');
    end;

    [Test]
    procedure SetReadOnlyMode_GetReadOnlyMode_ReturnsCorrectValue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act
        TableDataManager.SetReadOnlyMode(false);

        // Assert
        LibraryAssert.IsFalse(TableDataManager.GetReadOnlyMode(), 'GetReadOnlyMode should return false after setting to false');
    end;

    [Test]
    procedure GetControlSetNumber_ColumnSet0Position1_Returns1()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Initialize sets ColumnSetNumber to 0

        // Act
        Result := TableDataManager.GetControlSetNumber(1);

        // Assert
        LibraryAssert.AreEqual(1, Result, 'GetControlSetNumber should return 1 for column set 0 position 1');
    end;

    [Test]
    procedure GetControlSetNumber_ColumnSet2Position5_Returns25()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        TableDataManager.MoveToNextColumnSet(CaptionArray); // Move to set 1
        TableDataManager.MoveToNextColumnSet(CaptionArray); // Move to set 2

        // Act
        Result := TableDataManager.GetControlSetNumber(5);

        // Assert
        LibraryAssert.AreEqual(25, Result, 'GetControlSetNumber should return 25 for column set 2 position 5 (2*10+5)');
    end;

    [Test]
    procedure MoveToFirstColumnSet_ResetsToColumnSet0()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        TableDataManager.MoveToNextColumnSet(CaptionArray); // Move to set 1
        TableDataManager.MoveToNextColumnSet(CaptionArray); // Move to set 2

        // Act
        TableDataManager.MoveToFirstColumnSet();

        // Assert
        LibraryAssert.AreEqual(1, TableDataManager.GetControlSetNumber(1), 'GetControlSetNumber(1) should return 1 after MoveToFirstColumnSet');
    end;

    [Test]
    procedure MoveToPreviousColumnSet_AtColumnSet0_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Column set is 0

        // Act
        Result := TableDataManager.MoveToPreviousColumnSet();

        // Assert
        LibraryAssert.IsFalse(Result, 'MoveToPreviousColumnSet should return false when already at column set 0');
    end;

    [Test]
    procedure MoveToPreviousColumnSet_AtColumnSet1_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        TableDataManager.MoveToNextColumnSet(CaptionArray); // Move to set 1

        // Act
        Result := TableDataManager.MoveToPreviousColumnSet();

        // Assert
        LibraryAssert.IsTrue(Result, 'MoveToPreviousColumnSet should return true when moving from column set 1');
        LibraryAssert.AreEqual(1, TableDataManager.GetControlSetNumber(1), 'Should be back at column set 0');
    end;

    [Test]
    procedure GetMaxFieldCount_Returns500()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act
        Result := TableDataManager.GetMaxFieldCount();

        // Assert
        LibraryAssert.AreEqual(500, Result, 'GetMaxFieldCount should return 500');
    end;

    [Test]
    procedure GetColumnsPerPage_Returns10()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act
        Result := TableDataManager.GetColumnsPerPage();

        // Assert
        LibraryAssert.AreEqual(10, Result, 'GetColumnsPerPage should return 10');
    end;

    [Test]
    procedure GetMaxPrimaryKeyFields_Returns5()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act
        Result := TableDataManager.GetMaxPrimaryKeyFields();

        // Assert
        LibraryAssert.AreEqual(5, Result, 'GetMaxPrimaryKeyFields should return 5');
    end;

    [Test]
    procedure GetTableCaption_CustomerTable_ReturnsCustomer()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Text;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Table 18 = Customer

        // Act
        Result := TableDataManager.GetTableCaption();

        // Assert
        LibraryAssert.IsTrue(Result <> '', 'GetTableCaption should return a non-empty caption for Customer table');
        LibraryAssert.IsTrue(StrPos(Result, 'Customer') > 0, 'Caption should contain "Customer"');
    end;

    [Test]
    procedure IsSensitiveTable_GLEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(17, CompanyName); // Table 17 = G/L Entry

        // Act
        Result := TableDataManager.IsSensitiveTable();

        // Assert
        LibraryAssert.IsTrue(Result, 'IsSensitiveTable should return true for G/L Entry table (17)');
    end;

    [Test]
    procedure IsSensitiveTable_Customer_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Table 18 = Customer

        // Act
        Result := TableDataManager.IsSensitiveTable();

        // Assert
        LibraryAssert.IsFalse(Result, 'IsSensitiveTable should return false for Customer table (18)');
    end;

    [Test]
    procedure IsSensitiveTable_CustLedgerEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(21, CompanyName); // Table 21 = Cust. Ledger Entry

        // Act
        Result := TableDataManager.IsSensitiveTable();

        // Assert
        LibraryAssert.IsTrue(Result, 'IsSensitiveTable should return true for Cust. Ledger Entry table (21)');
    end;

    [Test]
    procedure IsSensitiveTable_VATEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(254, CompanyName); // Table 254 = VAT Entry

        // Act
        Result := TableDataManager.IsSensitiveTable();

        // Assert
        LibraryAssert.IsTrue(Result, 'IsSensitiveTable should return true for VAT Entry table (254)');
    end;

    #endregion

    #region FieldValueHandler Tests

    [Test]
    procedure EvaluateBooleanText_Yes_ReturnsTrue()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Arrange & Act
        Result := FieldValueHandler.EvaluateBooleanText('Yes');

        // Assert
        LibraryAssert.IsTrue(Result, 'EvaluateBooleanText should return true for "Yes"');
    end;

    [Test]
    procedure EvaluateBooleanText_No_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Arrange & Act
        Result := FieldValueHandler.EvaluateBooleanText('No');

        // Assert
        LibraryAssert.IsFalse(Result, 'EvaluateBooleanText should return false for "No"');
    end;

    [Test]
    procedure EvaluateBooleanText_EmptyString_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Arrange & Act
        Result := FieldValueHandler.EvaluateBooleanText('');

        // Assert
        LibraryAssert.IsFalse(Result, 'EvaluateBooleanText should return false for empty string');
    end;

    [Test]
    procedure EvaluateBooleanText_True_ReturnsTrue()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Arrange & Act
        Result := FieldValueHandler.EvaluateBooleanText('true');

        // Assert
        LibraryAssert.IsTrue(Result, 'EvaluateBooleanText should return true for "true"');
    end;

    [Test]
    procedure EvaluateBooleanText_False_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Arrange & Act
        Result := FieldValueHandler.EvaluateBooleanText('false');

        // Assert
        LibraryAssert.IsFalse(Result, 'EvaluateBooleanText should return false for "false"');
    end;

    [Test]
    procedure ValidateFieldEditable_NormalField_Passes()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
    begin
        // Arrange - Field "No." in Customer table (18) is a normal, editable field
        // Act & Assert - Should not raise an error
        FieldValueHandler.ValidateFieldEditable(18, 1); // Field 1 = No. (Code field)
    end;

    [Test]
    procedure ValidateFieldEditable_FlowField_RaisesError()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
    begin
        // Arrange - Field "Balance (LCY)" in Customer table (18) is a FlowField
        // Act & Assert
        asserterror FieldValueHandler.ValidateFieldEditable(18, 60); // Field 60 = Balance (LCY), a FlowField
        LibraryAssert.ExpectedError('is a FlowField and cannot be edited directly');
    end;

    [Test]
    procedure HasTableRelation_CurrencyCodeInCustomer_ReturnsTrue()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        TableRelationsMetadata: Record "Table Relations Metadata";
        Result: Boolean;
    begin
        // Arrange - Field "Currency Code" in Customer table (18) has a relation to Currency table
        // Act
        Result := FieldValueHandler.HasTableRelation(18, 21, TableRelationsMetadata); // Field 21 = Currency Code

        // Assert
        LibraryAssert.IsTrue(Result, 'HasTableRelation should return true for Customer."Currency Code"');
    end;

    [Test]
    procedure HasTableRelation_NameInCustomer_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        TableRelationsMetadata: Record "Table Relations Metadata";
        Result: Boolean;
    begin
        // Arrange - Field "Name" in Customer table (18) has no table relation
        // Act
        Result := FieldValueHandler.HasTableRelation(18, 2, TableRelationsMetadata); // Field 2 = Name

        // Assert
        LibraryAssert.IsFalse(Result, 'HasTableRelation should return false for Customer.Name');
    end;

    [Test]
    procedure HasTableRelation_PaymentTermsCodeInCustomer_ReturnsTrue()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        TableRelationsMetadata: Record "Table Relations Metadata";
        Result: Boolean;
    begin
        // Arrange - Field "Payment Terms Code" in Customer table (18) has a relation to Payment Terms table
        // Act
        Result := FieldValueHandler.HasTableRelation(18, 27, TableRelationsMetadata); // Field 27 = Payment Terms Code

        // Assert
        LibraryAssert.IsTrue(Result, 'HasTableRelation should return true for Customer."Payment Terms Code"');
    end;

    #endregion

    #region RecordWriter Tests

    [Test]
    procedure GuardReadOnlyMode_ReadOnlyTrue_RaisesError()
    var
        RecordWriter: Codeunit "Record Writer";
    begin
        // Arrange & Act & Assert
        asserterror RecordWriter.GuardReadOnlyMode(true);
        LibraryAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    procedure GuardReadOnlyMode_ReadOnlyFalse_NoError()
    var
        RecordWriter: Codeunit "Record Writer";
    begin
        // Arrange & Act & Assert - Should not raise an error
        RecordWriter.GuardReadOnlyMode(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ModifyRecord_ReadOnlyTrue_RaisesError()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");
        RecordReference.FindFirst();

        // Act & Assert
        asserterror RecordWriter.ModifyRecord(RecordReference, true, true);
        LibraryAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure InsertRecord_ReadOnlyTrue_RaisesError()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");
        RecordReference.Init();

        // Act & Assert
        asserterror RecordWriter.InsertRecord(RecordReference, true, true);
        LibraryAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteRecord_ReadOnlyTrue_RaisesError()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");
        RecordReference.FindFirst();

        // Act & Assert
        asserterror RecordWriter.DeleteRecord(RecordReference, true, true);
        LibraryAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    #endregion

}
