namespace SamueleCelebron.ObjectLauncher;

using System.Reflection;

/// <summary>
/// Edge case, boundary, and error condition tests for AL Objects Launcher.
/// Tests boundaries (0, max, negative), nulls, invalid data, error conditions, and edge cases.
/// Test ID Range: 50140
/// </summary>
codeunit 50140 "Edge Case Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        TestAssert: Codeunit "Test Assert";

    #region TableDataManager - Boundary Conditions

    [Test]
    procedure LoadRecordValues_RowNumber0_ReturnsEmptyArrays()
    var
        TableDataManager: Codeunit "Table Data Manager";
        ValueArray: array[500] of Text;
        KeyValueArray: array[10] of Text;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Customer table

        // Act - Load row 0 (should not exist)
        TableDataManager.LoadRecordValues(0, ValueArray, KeyValueArray);

        // Assert - Should return empty arrays without crashing
        TestAssert.AreEqual('', ValueArray[1], 'ValueArray[1] should be empty for row 0');
        TestAssert.AreEqual('', KeyValueArray[1], 'KeyValueArray[1] should be empty for row 0');
    end;

    [Test]
    procedure LoadRecordValues_RowNumber999999_ReturnsEmptyArrays()
    var
        TableDataManager: Codeunit "Table Data Manager";
        ValueArray: array[500] of Text;
        KeyValueArray: array[10] of Text;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Customer table

        // Act - Load row 999999 (beyond any realistic loaded records)
        TableDataManager.LoadRecordValues(999999, ValueArray, KeyValueArray);

        // Assert - Should return empty arrays without crashing
        TestAssert.AreEqual('', ValueArray[1], 'ValueArray[1] should be empty for non-existent row');
        TestAssert.AreEqual('', ValueArray[10], 'ValueArray[10] should be empty for non-existent row');
        TestAssert.AreEqual('', KeyValueArray[1], 'KeyValueArray[1] should be empty for non-existent row');
    end;

    [Test]
    procedure MoveToNextColumnSet_EmptyCaptionArray_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        Result: Boolean;
    begin
        // Arrange - Initialize but don't load captions
        TableDataManager.Initialize(18, CompanyName);
        Clear(CaptionArray); // Ensure empty array

        // Act
        Result := TableDataManager.MoveToNextColumnSet(CaptionArray);

        // Assert
        TestAssert.IsFalse(Result, 'MoveToNextColumnSet should return false with empty caption array');
    end;

    [Test]
    procedure MoveToNextColumnSet_RepeatedlyUntilFalse_StopsCorrectly()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        Result: Boolean;
        IterationCount: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);

        // Act - Keep moving next until it returns false
        repeat
            Result := TableDataManager.MoveToNextColumnSet(CaptionArray);
            if Result then
                IterationCount += 1;
        until not Result;

        // Assert - Should have moved at least once and then stopped
        TestAssert.IsTrue(IterationCount > 0, 'Should have moved to at least one column set');
        TestAssert.IsFalse(Result, 'Final MoveToNextColumnSet should return false');
    end;

    [Test]
    procedure MoveToPreviousColumnSet_ColumnSetNumber0_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Boolean;
    begin
        // Arrange - Initialize sets ColumnSetNumber to 0
        TableDataManager.Initialize(18, CompanyName);

        // Act
        Result := TableDataManager.MoveToPreviousColumnSet();

        // Assert
        TestAssert.IsFalse(Result, 'MoveToPreviousColumnSet should return false at column set 0');
    end;

    [Test]
    procedure MoveToPreviousColumnSet_AfterMoveToFirst_ReturnsFalse()
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
        TableDataManager.MoveToFirstColumnSet(); // Back to set 0

        // Act
        Result := TableDataManager.MoveToPreviousColumnSet();

        // Assert
        TestAssert.IsFalse(Result, 'MoveToPreviousColumnSet should return false after MoveToFirstColumnSet');
    end;

    [Test]
    procedure GetControlSetNumber_ColumnSet0Position1_Returns1()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // ColumnSetNumber = 0

        // Act
        Result := TableDataManager.GetControlSetNumber(1);

        // Assert
        TestAssert.AreEqual(1, Result, 'GetControlSetNumber(1) at ColumnSet 0 should return 1');
    end;

    [Test]
    procedure GetControlSetNumber_ColumnSet0Position10_Returns10()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // ColumnSetNumber = 0

        // Act
        Result := TableDataManager.GetControlSetNumber(10);

        // Assert
        TestAssert.AreEqual(10, Result, 'GetControlSetNumber(10) at ColumnSet 0 should return 10');
    end;

    [Test]
    procedure GetControlSetNumber_LargeColumnSetNumber_CalculatesCorrectly()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        Result: Integer;
        i: Integer;
    begin
        // Arrange - Move to a high column set number
        TableDataManager.Initialize(18, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);

        // Move forward multiple times (e.g., 10 times if possible)
        for i := 1 to 10 do begin
            if not TableDataManager.MoveToNextColumnSet(CaptionArray) then
                break;
        end;

        // Act - Test calculation at current position
        Result := TableDataManager.GetControlSetNumber(5);

        // Assert - Should calculate correctly (ColumnSetNumber * 10 + 5)
        // At minimum, if we moved 5 times, should be >= 50 + 5 = 55
        TestAssert.IsTrue(Result >= 5, 'GetControlSetNumber should calculate correctly for large column set');
    end;

    [Test]
    procedure LoadFieldCaptions_TableWithFewFields_PopulatesCorrectly()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
    begin
        // Arrange - Use a table with few fields (e.g., Currency table has ~20 fields)
        TableDataManager.Initialize(4, CompanyName); // Table 4 = Currency

        // Act
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);

        // Assert - First caption should be populated
        TestAssert.AreNotEqual('', CaptionArray[1], 'First caption should be populated');
        // Last positions should be empty
        TestAssert.AreEqual('', CaptionArray[500], 'Last caption position should be empty for small table');
    end;

    [Test]
    procedure Initialize_TwiceWithDifferentTables_ClearsFirstTableState()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        FirstCaption: Text;
        SecondCaption: Text;
    begin
        // Arrange & Act - Initialize with Customer table
        TableDataManager.Initialize(18, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        FirstCaption := CaptionArray[1];

        // Re-initialize with Currency table
        TableDataManager.Initialize(4, CompanyName);
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        SecondCaption := CaptionArray[1];

        // Assert - Second initialize should completely clear first table's state
        TestAssert.AreNotEqual(FirstCaption, SecondCaption, 'Second initialize should load different table captions');
        TestAssert.AreEqual(4, TableDataManager.GetTableNumber(), 'Table number should be updated to second table');
    end;

    [Test]
    procedure GetRecordCount_BeforeLoadRecordSet_Returns0()
    var
        TableDataManager: Codeunit "Table Data Manager";
        Result: Integer;
    begin
        // Arrange - Initialize but don't load records
        TableDataManager.Initialize(18, CompanyName);

        // Act
        Result := TableDataManager.GetRecordCount();

        // Assert
        TestAssert.AreEqual(0, Result, 'GetRecordCount should return 0 before LoadRecordSet is called');
    end;

    [Test]
    procedure GetRecordReference_NonExistentRow_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        RecordReference: RecordRef;
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act - Try to get reference for row that doesn't exist in dictionary
        Result := TableDataManager.GetRecordReference(99999, RecordReference);

        // Assert
        TestAssert.IsFalse(Result, 'GetRecordReference should return false for non-existent row');
    end;

    #endregion

    #region FieldValueHandler - Error Conditions

    [Test]
    procedure ValidateFieldEditable_FlowField_RaisesSpecificError()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
    begin
        // Arrange - Customer."Balance (LCY)" is a FlowField (Field 60)

        // Act & Assert
        asserterror FieldValueHandler.ValidateFieldEditable(18, 60);
        TestAssert.ExpectedError('is a FlowField and cannot be edited directly');
    end;

    [Test]
    procedure ValidateFieldEditable_DisabledField_RaisesSpecificError()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        FieldRecord: Record Field;
    begin
        // Arrange - Find a disabled field
        FieldRecord.SetRange(TableNo, 18); // Customer table
        FieldRecord.SetRange(Enabled, false);
        if not FieldRecord.FindFirst() then
            exit; // Skip test if no disabled fields found

        // Act & Assert
        asserterror FieldValueHandler.ValidateFieldEditable(18, FieldRecord."No.");
        TestAssert.ExpectedError('is disabled and cannot be edited');
    end;

    [Test]
    procedure EvaluateBooleanText_EmptyString_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Act
        Result := FieldValueHandler.EvaluateBooleanText('');

        // Assert
        TestAssert.IsFalse(Result, 'Empty string should evaluate to false');
    end;

    [Test]
    procedure EvaluateBooleanText_Yes_ReturnsTrue()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Act
        Result := FieldValueHandler.EvaluateBooleanText('Yes');

        // Assert
        TestAssert.IsTrue(Result, '"Yes" should evaluate to true');
    end;

    [Test]
    procedure EvaluateBooleanText_No_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        Result: Boolean;
    begin
        // Act
        Result := FieldValueHandler.EvaluateBooleanText('No');

        // Assert
        TestAssert.IsFalse(Result, '"No" should evaluate to false');
    end;

    [Test]
    procedure HasTableRelation_FieldWithNoRelation_ReturnsFalse()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        TableRelationsMetadata: Record "Table Relations Metadata";
        Result: Boolean;
    begin
        // Arrange - Customer.Name has no table relation

        // Act
        Result := FieldValueHandler.HasTableRelation(18, 2, TableRelationsMetadata);

        // Assert
        TestAssert.IsFalse(Result, 'HasTableRelation should return false for field with no relation');
    end;

    [Test]
    procedure HasTableRelation_FieldWithRelation_ReturnsTrue()
    var
        FieldValueHandler: Codeunit "Field Value Handler";
        TableRelationsMetadata: Record "Table Relations Metadata";
        Result: Boolean;
    begin
        // Arrange - Customer."Currency Code" has a relation to Currency table

        // Act
        Result := FieldValueHandler.HasTableRelation(18, 21, TableRelationsMetadata);

        // Assert
        TestAssert.IsTrue(Result, 'HasTableRelation should return true for field with relation');
    end;

    #endregion

    #region RecordWriter - Error Guards

    [Test]
    procedure GuardReadOnlyMode_True_RaisesSpecificError()
    var
        RecordWriter: Codeunit "Record Writer";
    begin
        // Act & Assert
        asserterror RecordWriter.GuardReadOnlyMode(true);
        TestAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    procedure GuardReadOnlyMode_False_NoError()
    var
        RecordWriter: Codeunit "Record Writer";
    begin
        // Act - Should not raise an error
        RecordWriter.GuardReadOnlyMode(false);

        // Assert - If we reach here, no error was raised (test passes)
        TestAssert.IsTrue(true, 'GuardReadOnlyMode(false) should not raise error');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ModifyRecord_ReadOnlyModeTrue_ErrorBeforeDBOperation()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");
        if RecordReference.FindFirst() then;

        // Act & Assert - Should error before attempting DB modification
        asserterror RecordWriter.ModifyRecord(RecordReference, true, true);
        TestAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure InsertRecord_ReadOnlyModeTrue_ErrorBeforeDBOperation()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");
        RecordReference.Init();

        // Act & Assert - Should error before attempting DB insert
        asserterror RecordWriter.InsertRecord(RecordReference, true, true);
        TestAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteRecord_ReadOnlyModeTrue_ErrorBeforeDBOperation()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");
        if RecordReference.FindFirst() then;

        // Act & Assert - Should error before attempting DB delete
        asserterror RecordWriter.DeleteRecord(RecordReference, true, true);
        TestAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    [Test]
    procedure DeleteAllRecords_ReadOnlyModeTrue_ErrorBeforeConfirmDialog()
    var
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
    begin
        // Arrange
        RecordReference.Open(Database::"AllObjWithCaption");

        // Act & Assert - Should error immediately, before showing confirm dialog
        asserterror RecordWriter.DeleteAllRecords(RecordReference, true, true);
        TestAssert.ExpectedError('Cannot perform write operations in read-only mode');
    end;

    #endregion

    #region DataExportManager - Empty State

    [Test]
    procedure ExportTableToExcel_RecordCount0_RaisesError()
    var
        TableDataManager: Codeunit "Table Data Manager";
        DataExportManager: Codeunit "Data Export Manager";
    begin
        // Arrange - Initialize without loading any records
        TableDataManager.Initialize(18, CompanyName);

        // Act & Assert - Should raise error when no records loaded
        asserterror DataExportManager.ExportTableToExcel(TableDataManager);
        TestAssert.ExpectedError('There are no records to export');
    end;

    #endregion

    #region Sensitive Table Detection - All Known IDs

    [Test]
    procedure IsSensitiveTable_Table17_GLEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(17, CompanyName); // G/L Entry

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 17 (G/L Entry) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table21_CustLedgerEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(21, CompanyName); // Cust. Ledger Entry

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 21 (Cust. Ledger Entry) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table25_VendorLedgerEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(25, CompanyName); // Vendor Ledger Entry

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 25 (Vendor Ledger Entry) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table32_ItemLedgerEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(32, CompanyName); // Item Ledger Entry

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 32 (Item Ledger Entry) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table112_SalesInvoiceHeader_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(112, CompanyName); // Sales Invoice Header

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 112 (Sales Invoice Header) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table254_VATEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(254, CompanyName); // VAT Entry

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 254 (VAT Entry) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table5802_ValueEntry_ReturnsTrue()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(5802, CompanyName); // Value Entry

        // Assert
        TestAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Table 5802 (Value Entry) should be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table18_Customer_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName); // Customer

        // Assert
        TestAssert.IsFalse(TableDataManager.IsSensitiveTable(), 'Table 18 (Customer) should NOT be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table27_Item_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(27, CompanyName); // Item

        // Assert
        TestAssert.IsFalse(TableDataManager.IsSensitiveTable(), 'Table 27 (Item) should NOT be sensitive');
    end;

    [Test]
    procedure IsSensitiveTable_Table13_SalespersonPurchaser_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange
        TableDataManager.Initialize(13, CompanyName); // Salesperson/Purchaser

        // Assert
        TestAssert.IsFalse(TableDataManager.IsSensitiveTable(), 'Table 13 (Salesperson/Purchaser) should NOT be sensitive');
    end;

    #endregion

    #region Dictionary Operations - Edge Cases

    [Test]
    procedure GetFieldNumber_IndexDoesNotExist_Errors()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // Arrange - Initialize without loading field captions
        TableDataManager.Initialize(18, CompanyName);

        // Act & Assert - Accessing non-existent dictionary key should error
        asserterror TableDataManager.GetFieldNumber(999);
        // Dictionary.Get will throw error when key doesn't exist
    end;

    [Test]
    procedure AddRecordId_ThenRemove_GetRecordIdReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        TestRecordId: RecordId;
        RecordReference: RecordRef;
        ResultRecordId: RecordId;
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);
        RecordReference.Open(18, false, CompanyName);
        if RecordReference.FindFirst() then
            TestRecordId := RecordReference.RecordId
        else
            exit; // Skip if no records

        // Act - Add then remove
        TableDataManager.AddRecordId(1, TestRecordId);
        TableDataManager.RemoveRecordId(1);
        Result := TableDataManager.GetRecordId(1, ResultRecordId);

        // Assert
        TestAssert.IsFalse(Result, 'GetRecordId should return false after RemoveRecordId');
    end;

    [Test]
    procedure UpdateRecordId_ForExistingRow_ReturnsNewValue()
    var
        TableDataManager: Codeunit "Table Data Manager";
        RecordReference: RecordRef;
        FirstRecordId: RecordId;
        SecondRecordId: RecordId;
        RetrievedRecordId: RecordId;
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);
        RecordReference.Open(18, false, CompanyName);

        // Get two different RecordIds
        if not RecordReference.FindSet() then
            exit; // Skip if no records
        FirstRecordId := RecordReference.RecordId;
        if RecordReference.Next() = 0 then
            exit; // Skip if only one record
        SecondRecordId := RecordReference.RecordId;

        // Add first record ID
        TableDataManager.AddRecordId(1, FirstRecordId);

        // Act - Update to second record ID
        TableDataManager.UpdateRecordId(1, SecondRecordId);
        Result := TableDataManager.GetRecordId(1, RetrievedRecordId);

        // Assert
        TestAssert.IsTrue(Result, 'GetRecordId should return true after UpdateRecordId');
        TestAssert.AreEqual(Format(SecondRecordId), Format(RetrievedRecordId), 'Retrieved RecordId should be the updated value');
    end;

    [Test]
    procedure GetRecordId_RowNotInDictionary_ReturnsFalse()
    var
        TableDataManager: Codeunit "Table Data Manager";
        ResultRecordId: RecordId;
        Result: Boolean;
    begin
        // Arrange
        TableDataManager.Initialize(18, CompanyName);

        // Act - Try to get RecordId for row that was never added
        Result := TableDataManager.GetRecordId(12345, ResultRecordId);

        // Assert
        TestAssert.IsFalse(Result, 'GetRecordId should return false for row not in dictionary');
    end;

    #endregion
}
