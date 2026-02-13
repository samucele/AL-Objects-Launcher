namespace SamueleCelebron.ObjectLauncher;

using System.Utilities;
using System.TestLibraries.Utilities;
using Microsoft.CRM.Team;

/// <summary>
/// End-to-end scenario tests for the AL Objects Launcher extension.
/// Tests complete user workflows from initialization through CRUD operations,
/// verifying the full interaction between TableDataManager, RecordWriter, and FieldValueHandler.
/// Test Codeunit ID: 50130
/// </summary>
codeunit 50130 "Obj. Launcher Scenario Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryAssert: Codeunit "Library Assert";

    #region Scenario 1: Browse Any Table (Read-Only Workflow)

    /// <summary>
    /// Scenario 1: Browse Any Table - Complete read-only workflow
    /// User browses Customer table, loads metadata, navigates columns, retrieves data.
    /// Tests: Initialize, LoadFieldCaptions, LoadRecordSet, LoadRecordValues, Column Navigation
    /// </summary>
    [Test]
    procedure BrowseCustomerTable_ReadOnlyWorkflow_Success()
    var
        TempSourceRecord: Record Integer temporary;
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        ValueArray: array[500] of Text;
        KeyValueArray: array[10] of Text;
        RecordCount: Integer;
        TableCaption: Text;
    begin
        // [GIVEN] A Table Data Manager initialized for Customer table (18)
        TableDataManager.Initialize(18, CompanyName());

        // [WHEN] Load field captions and verify captions populated
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);

        // [THEN] Caption array should have field captions loaded
        LibraryAssert.AreNotEqual('', CaptionArray[1], 'First caption should be populated');
        LibraryAssert.AreNotEqual('', KeyCaptionArray[1], 'First key caption should be populated');

        // [WHEN] Load record set
        RecordCount := TableDataManager.LoadRecordSet(TempSourceRecord);

        // [THEN] Records should be loaded
        LibraryAssert.IsTrue(RecordCount >= 0, 'Record count should be non-negative');
        LibraryAssert.AreEqual(RecordCount, TempSourceRecord.Count, 'Source record count matches TDM count');

        // [WHEN] Load record values for first row (if records exist)
        if RecordCount > 0 then begin
            TableDataManager.LoadRecordValues(1, ValueArray, KeyValueArray);

            // [THEN] Values should be populated
            LibraryAssert.IsTrue(ValueArray[1] <> '', 'First field value should be populated');
        end;

        // [WHEN] Navigate to next column set
        // [THEN] Should succeed because Customer table has many fields
        LibraryAssert.IsTrue(TableDataManager.MoveToNextColumnSet(CaptionArray), 'Should move to next column set');
        LibraryAssert.AreEqual(11, TableDataManager.GetControlSetNumber(1), 'First control in set 1 should be column 11');

        // [WHEN] Move to previous column set
        // [THEN] Should return to first set
        LibraryAssert.IsTrue(TableDataManager.MoveToPreviousColumnSet(), 'Should move back to previous column set');
        LibraryAssert.AreEqual(1, TableDataManager.GetControlSetNumber(1), 'Should be back at column 1');

        // [WHEN] Navigate to last and first column sets
        TableDataManager.MoveToLastColumnSet();
        LibraryAssert.IsTrue(TableDataManager.GetControlSetNumber(1) > 10, 'Should be at a later column set');

        TableDataManager.MoveToFirstColumnSet();
        LibraryAssert.AreEqual(1, TableDataManager.GetControlSetNumber(1), 'Should be back at first column set');

        // [WHEN] Get table caption
        TableCaption := TableDataManager.GetTableCaption();

        // [THEN] Caption should be 'Customer'
        LibraryAssert.AreEqual('Customer', TableCaption, 'Table caption should be Customer');
    end;

    #endregion

    #region Scenario 2: Full CRUD Cycle on a Table

    /// <summary>
    /// Scenario 2: Full CRUD Cycle - Insert, modify, delete workflow
    /// User performs complete CRUD operations on Salesperson/Purchaser table.
    /// Tests: InsertRecord, ModifyRecord, DeleteRecord, CountRecords
    /// </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure FullCRUDCycle_SalespersonTable_Success()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TempSourceRecord: Record Integer temporary;
        TableDataManager: Codeunit "Table Data Manager";
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        InitialCount: Integer;
        NewRecordCount: Integer;
        TestCode: Code[20];
        TestName: Text[50];
        NewRowNumber: Integer;
    begin
        // [GIVEN] A Table Data Manager initialized for Salesperson/Purchaser table (13)
        TableDataManager.Initialize(13, CompanyName());
        TableDataManager.SetReadOnlyMode(false);
        TableDataManager.LoadRecordSet(TempSourceRecord);
        InitialCount := TableDataManager.GetRecordCount();

        // [GIVEN] A unique test code
        TestCode := CopyStr('TEST-' + Format(CreateGuid()), 1, 20);
        TestName := 'Test Salesperson ' + Format(CurrentDateTime);

        // [WHEN] Create a new record via RecordRef and insert
        TableDataManager.OpenRecordReference(RecordReference);
        FieldReference := RecordReference.Field(1); // Code field
        FieldReference.Value := TestCode;
        FieldReference := RecordReference.Field(2); // Name field
        FieldReference.Value := TestName;

        RecordWriter.InsertRecord(RecordReference, TableDataManager.GetRunTriggers(), TableDataManager.GetReadOnlyMode());

        // [GIVEN] Add record to TDM dictionary
        NewRowNumber := InitialCount + 1;
        TableDataManager.AddRecordId(NewRowNumber, RecordReference.RecordId);

        // [THEN] Record count should increase
        TableDataManager.CountRecords();
        NewRecordCount := TableDataManager.GetRecordCount();
        LibraryAssert.AreEqual(InitialCount + 1, NewRecordCount, 'Record count should increase by 1 after insert');

        // [THEN] Verify record exists in database
        LibraryAssert.IsTrue(SalespersonPurchaser.Get(TestCode), 'Record should exist in database');
        LibraryAssert.AreEqual(TestName, SalespersonPurchaser.Name, 'Name should match');

        // [WHEN] Modify the record
        RecordReference.Close();
        LibraryAssert.IsTrue(TableDataManager.GetRecordReference(NewRowNumber, RecordReference), 'Should retrieve record reference');
        FieldReference := RecordReference.Field(2); // Name field
        FieldReference.Value := 'Modified Name';
        RecordWriter.ModifyRecord(RecordReference, TableDataManager.GetRunTriggers(), TableDataManager.GetReadOnlyMode());

        // [THEN] Verify modification persisted
        SalespersonPurchaser.Get(TestCode);
        LibraryAssert.AreEqual('Modified Name', SalespersonPurchaser.Name, 'Name should be modified');

        // [WHEN] Delete the record
        RecordReference.Close();
        LibraryAssert.IsTrue(TableDataManager.GetRecordReference(NewRowNumber, RecordReference), 'Should retrieve record reference for delete');
        RecordWriter.DeleteRecord(RecordReference, TableDataManager.GetRunTriggers(), TableDataManager.GetReadOnlyMode());

        // [GIVEN] Remove from dictionary
        TableDataManager.RemoveRecordId(NewRowNumber);

        // [THEN] Verify record deleted
        TableDataManager.CountRecords();
        LibraryAssert.AreEqual(InitialCount, TableDataManager.GetRecordCount(), 'Record count should return to initial value');
        LibraryAssert.IsFalse(SalespersonPurchaser.Get(TestCode), 'Record should not exist in database');
    end;

    #endregion

    #region Scenario 3: Read-Only Mode Prevents All Writes

    /// <summary>
    /// Scenario 3: Read-Only Mode Protection
    /// Verifies that all write operations are blocked when ReadOnlyMode is true.
    /// Tests: InsertRecord, ModifyRecord, DeleteRecord with ReadOnlyMode
    /// </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReadOnlyMode_BlocksAllWriteOperations_ErrorsOccur()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TableDataManager: Codeunit "Table Data Manager";
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        TestCode: Code[20];
        InsertErrorOccurred: Boolean;
        ModifyErrorOccurred: Boolean;
        DeleteErrorOccurred: Boolean;
    begin
        // [GIVEN] A Table Data Manager in default ReadOnlyMode (true)
        TableDataManager.Initialize(13, CompanyName());
        LibraryAssert.IsTrue(TableDataManager.GetReadOnlyMode(), 'Should default to ReadOnlyMode');

        // [GIVEN] A test salesperson record exists in the database
        TestCode := CopyStr('READONLY-' + Format(CreateGuid()), 1, 20);
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Code := TestCode;
        SalespersonPurchaser.Name := 'Read Only Test';
        SalespersonPurchaser.Insert();

        // [WHEN] Try to insert a record with ReadOnlyMode = true
        TableDataManager.OpenRecordReference(RecordReference);
        FieldReference := RecordReference.Field(1);
        FieldReference.Value := CopyStr('NEW-' + Format(CreateGuid()), 1, 20);

        InsertErrorOccurred := false;
        asserterror RecordWriter.InsertRecord(RecordReference, true, TableDataManager.GetReadOnlyMode());
        InsertErrorOccurred := GetLastErrorText() <> '';

        // [THEN] Insert should fail
        LibraryAssert.IsTrue(InsertErrorOccurred, 'Insert should fail in ReadOnlyMode');
        ClearLastError();

        // [GIVEN] Re-insert the test record (asserterror rolled back the previous insert)
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Code := TestCode;
        SalespersonPurchaser.Name := 'Read Only Test';
        SalespersonPurchaser.Insert();

        // [WHEN] Try to modify a record with ReadOnlyMode = true
        RecordReference.Close();
        RecordReference.Open(13, false, CompanyName());
        RecordReference.Get(SalespersonPurchaser.RecordId);
        FieldReference := RecordReference.Field(2);
        FieldReference.Value := 'Modified in ReadOnly';

        ModifyErrorOccurred := false;
        asserterror RecordWriter.ModifyRecord(RecordReference, true, TableDataManager.GetReadOnlyMode());
        ModifyErrorOccurred := GetLastErrorText() <> '';

        // [THEN] Modify should fail
        LibraryAssert.IsTrue(ModifyErrorOccurred, 'Modify should fail in ReadOnlyMode');
        ClearLastError();

        // [GIVEN] Re-insert the test record (asserterror rolled back again)
        SalespersonPurchaser.Init();
        SalespersonPurchaser.Code := TestCode;
        SalespersonPurchaser.Name := 'Read Only Test';
        SalespersonPurchaser.Insert();

        // [WHEN] Try to delete a record with ReadOnlyMode = true
        RecordReference.Close();
        RecordReference.Open(13, false, CompanyName());
        RecordReference.Get(SalespersonPurchaser.RecordId);

        DeleteErrorOccurred := false;
        asserterror RecordWriter.DeleteRecord(RecordReference, true, TableDataManager.GetReadOnlyMode());
        DeleteErrorOccurred := GetLastErrorText() <> '';

        // [THEN] Delete should fail
        LibraryAssert.IsTrue(DeleteErrorOccurred, 'Delete should fail in ReadOnlyMode');
        ClearLastError();

        // [WHEN] Set ReadOnlyMode to false
        TableDataManager.SetReadOnlyMode(false);

        // [THEN] Insert should now succeed
        RecordReference.Close();
        TableDataManager.OpenRecordReference(RecordReference);
        FieldReference := RecordReference.Field(1);
        FieldReference.Value := CopyStr('WRITE-' + Format(CreateGuid()), 1, 20);
        FieldReference := RecordReference.Field(2);
        FieldReference.Value := 'Write Mode Test';

        RecordWriter.InsertRecord(RecordReference, true, TableDataManager.GetReadOnlyMode());
        LibraryAssert.IsTrue(RecordReference.Get(RecordReference.RecordId), 'Record should be inserted when ReadOnlyMode is false');
    end;

    #endregion

    #region Scenario 4: Field Metadata Loading and Column Pagination

    /// <summary>
    /// Scenario 4: Field Metadata and Column Pagination
    /// Verifies field caption loading and column set navigation for tables with many fields.
    /// Tests: LoadFieldCaptions, GetControlSetNumber, MoveToNextColumnSet
    /// </summary>
    [Test]
    procedure FieldMetadataLoading_CustomerTablePagination_NavigatesCorrectly()
    var
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        FieldCount: Integer;
        ColumnSetNumber: Integer;
        HasMoreColumns: Boolean;
    begin
        // [GIVEN] A Table Data Manager initialized for Customer table (many fields)
        TableDataManager.Initialize(18, CompanyName());

        // [WHEN] Load field captions
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);

        // [THEN] Count populated captions (should be > 10 for pagination test)
        FieldCount := 0;
        while (FieldCount < ArrayLen(CaptionArray)) and (CaptionArray[FieldCount + 1] <> '') do
            FieldCount += 1;

        LibraryAssert.IsTrue(FieldCount > 10, 'Customer table should have more than 10 fields for pagination test');

        // [WHEN] Get control set number at column set 0
        LibraryAssert.AreEqual(1, TableDataManager.GetControlSetNumber(1), 'Column 1 in set 0 should be position 1');
        LibraryAssert.AreEqual(5, TableDataManager.GetControlSetNumber(5), 'Column 5 in set 0 should be position 5');

        // [WHEN] Move to next column set
        HasMoreColumns := TableDataManager.MoveToNextColumnSet(CaptionArray);
        LibraryAssert.IsTrue(HasMoreColumns, 'Should successfully move to next column set');

        // [THEN] Control set numbers should reflect new position
        LibraryAssert.AreEqual(11, TableDataManager.GetControlSetNumber(1), 'Column 1 in set 1 should be position 11');
        LibraryAssert.AreEqual(15, TableDataManager.GetControlSetNumber(5), 'Column 5 in set 1 should be position 15');

        // [WHEN] Move to next column set again
        HasMoreColumns := TableDataManager.MoveToNextColumnSet(CaptionArray);
        if HasMoreColumns then
            LibraryAssert.AreEqual(21, TableDataManager.GetControlSetNumber(1), 'Column 1 in set 2 should be position 21');

        // [WHEN] Continue moving until no more columns
        ColumnSetNumber := 0;
        TableDataManager.MoveToFirstColumnSet();
        repeat
            ColumnSetNumber += 1;
            HasMoreColumns := TableDataManager.MoveToNextColumnSet(CaptionArray);
        until not HasMoreColumns;

        // [THEN] Should eventually return false when at the end
        LibraryAssert.IsFalse(HasMoreColumns, 'Should return false when no more column sets available');
    end;

    #endregion

    #region Scenario 5: Sensitive Table Detection Workflow

    /// <summary>
    /// Scenario 5: Sensitive Table Detection
    /// Verifies that critical ledger and posted tables are correctly identified as sensitive.
    /// Tests: IsSensitiveTable for various table types
    /// </summary>
    [Test]
    procedure SensitiveTableDetection_VariousTables_IdentifiesCorrectly()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // [WHEN] Initialize with G/L Entry (17)
        TableDataManager.Initialize(17, CompanyName());
        // [THEN] Should be sensitive
        LibraryAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'G/L Entry should be sensitive');

        // [WHEN] Initialize with Customer (18)
        TableDataManager.Initialize(18, CompanyName());
        // [THEN] Should not be sensitive
        LibraryAssert.IsFalse(TableDataManager.IsSensitiveTable(), 'Customer should not be sensitive');

        // [WHEN] Initialize with Cust. Ledger Entry (21)
        TableDataManager.Initialize(21, CompanyName());
        // [THEN] Should be sensitive
        LibraryAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Cust. Ledger Entry should be sensitive');

        // [WHEN] Initialize with Vendor Ledger Entry (25)
        TableDataManager.Initialize(25, CompanyName());
        // [THEN] Should be sensitive
        LibraryAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Vendor Ledger Entry should be sensitive');

        // [WHEN] Initialize with Item Ledger Entry (32)
        TableDataManager.Initialize(32, CompanyName());
        // [THEN] Should be sensitive
        LibraryAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Item Ledger Entry should be sensitive');

        // [WHEN] Initialize with Sales Invoice Header (112)
        TableDataManager.Initialize(112, CompanyName());
        // [THEN] Should be sensitive
        LibraryAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'Sales Invoice Header should be sensitive');

        // [WHEN] Initialize with VAT Entry (254)
        TableDataManager.Initialize(254, CompanyName());
        // [THEN] Should be sensitive
        LibraryAssert.IsTrue(TableDataManager.IsSensitiveTable(), 'VAT Entry should be sensitive');

        // [WHEN] Initialize with Salesperson/Purchaser (13)
        TableDataManager.Initialize(13, CompanyName());
        // [THEN] Should not be sensitive
        LibraryAssert.IsFalse(TableDataManager.IsSensitiveTable(), 'Salesperson/Purchaser should not be sensitive');
    end;

    #endregion

    #region Scenario 6: Multiple Table Switches

    /// <summary>
    /// Scenario 6: Multiple Table Switches
    /// Verifies that switching between tables properly resets all state.
    /// Tests: Initialize clears previous state, metadata changes between tables
    /// </summary>
    [Test]
    procedure MultipleTableSwitches_CustomerToItem_StateResetsCorrectly()
    var
        TempSourceRecord: Record Integer temporary;
        TableDataManager: Codeunit "Table Data Manager";
        CaptionArray: array[500] of Text;
        KeyCaptionArray: array[10] of Text;
        CustomerCaption: Text;
        ItemCaption: Text;
        CustomerCount: Integer;
        ItemCount: Integer;
        CustomerFirstFieldCaption: Text;
        ItemFirstFieldCaption: Text;
    begin
        // [GIVEN] Initialize with Customer table (18)
        TableDataManager.Initialize(18, CompanyName());
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        CustomerFirstFieldCaption := CaptionArray[2]; // Use 2nd field (Name vs Description)
        CustomerCount := TableDataManager.LoadRecordSet(TempSourceRecord);
        CustomerCaption := TableDataManager.GetTableCaption();

        // [THEN] Verify Customer data loaded
        LibraryAssert.AreEqual('Customer', CustomerCaption, 'First table should be Customer');
        LibraryAssert.AreNotEqual('', CustomerFirstFieldCaption, 'Customer should have field captions');

        // [WHEN] Re-initialize with Item table (27)
        TableDataManager.Initialize(27, CompanyName());
        TableDataManager.LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        ItemFirstFieldCaption := CaptionArray[2]; // Use 2nd field (Name vs Description)
        ItemCount := TableDataManager.LoadRecordSet(TempSourceRecord);
        ItemCaption := TableDataManager.GetTableCaption();

        // [THEN] Verify Item data loaded and Customer state cleared
        LibraryAssert.AreEqual('Item', ItemCaption, 'Second table should be Item');
        LibraryAssert.AreNotEqual('', ItemFirstFieldCaption, 'Item should have field captions');
        LibraryAssert.AreNotEqual(CustomerFirstFieldCaption, ItemFirstFieldCaption, 'Second field captions should differ between tables');

        // [THEN] Record counts should reflect different tables
        // (They may be equal by coincidence, but state should be independent)
        LibraryAssert.AreEqual(27, TableDataManager.GetTableNumber(), 'Table number should be Item (27)');

        // [WHEN] Switch back to Customer (18)
        TableDataManager.Initialize(18, CompanyName());
        CustomerCaption := TableDataManager.GetTableCaption();

        // [THEN] Verify Customer table loaded again
        LibraryAssert.AreEqual('Customer', CustomerCaption, 'Should be back to Customer');
        LibraryAssert.AreEqual(18, TableDataManager.GetTableNumber(), 'Table number should be Customer (18)');
    end;

    #endregion

    #region Scenario 7: Configuration Flags Workflow

    /// <summary>
    /// Scenario 7: Configuration Flags
    /// Verifies that ValidateFields, RunTriggers, and ReadOnlyMode flags work correctly.
    /// Tests: SetValidateFields, SetRunTriggers, SetReadOnlyMode and getters
    /// </summary>
    [Test]
    procedure ConfigurationFlags_SetAndGet_WorkCorrectly()
    var
        TableDataManager: Codeunit "Table Data Manager";
    begin
        // [GIVEN] A newly initialized Table Data Manager
        TableDataManager.Initialize(13, CompanyName());

        // [THEN] Default values should be set
        LibraryAssert.IsTrue(TableDataManager.GetReadOnlyMode(), 'Should default to ReadOnlyMode = true');
        LibraryAssert.IsTrue(TableDataManager.GetValidateFields(), 'Should default to ValidateFields = true');
        LibraryAssert.IsTrue(TableDataManager.GetRunTriggers(), 'Should default to RunTriggers = true');

        // [WHEN] Change ReadOnlyMode to false
        TableDataManager.SetReadOnlyMode(false);
        // [THEN] Getter should reflect the change
        LibraryAssert.IsFalse(TableDataManager.GetReadOnlyMode(), 'ReadOnlyMode should be false');

        // [WHEN] Change ValidateFields to false
        TableDataManager.SetValidateFields(false);
        // [THEN] Getter should reflect the change
        LibraryAssert.IsFalse(TableDataManager.GetValidateFields(), 'ValidateFields should be false');

        // [WHEN] Change RunTriggers to false
        TableDataManager.SetRunTriggers(false);
        // [THEN] Getter should reflect the change
        LibraryAssert.IsFalse(TableDataManager.GetRunTriggers(), 'RunTriggers should be false');

        // [WHEN] Change back to true
        TableDataManager.SetReadOnlyMode(true);
        TableDataManager.SetValidateFields(true);
        TableDataManager.SetRunTriggers(true);

        // [THEN] All should be true again
        LibraryAssert.IsTrue(TableDataManager.GetReadOnlyMode(), 'ReadOnlyMode should be true again');
        LibraryAssert.IsTrue(TableDataManager.GetValidateFields(), 'ValidateFields should be true again');
        LibraryAssert.IsTrue(TableDataManager.GetRunTriggers(), 'RunTriggers should be true again');
    end;

    #endregion

    #region Scenario 8: Record Dictionary Management

    /// <summary>
    /// Scenario 8: Record Dictionary Management
    /// Verifies dictionary operations: Add, Get, Update, Remove.
    /// Tests: AddRecordId, GetRecordId, UpdateRecordId, RemoveRecordId
    /// </summary>
    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecordDictionary_AddUpdateRemove_WorksCorrectly()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TableDataManager: Codeunit "Table Data Manager";
        RecordWriter: Codeunit "Record Writer";
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        RetrievedRecordId: RecordId;
        TestCode1: Code[20];
        TestCode2: Code[20];
        RowNumber: Integer;
    begin
        // [GIVEN] A Table Data Manager initialized
        TableDataManager.Initialize(13, CompanyName());
        TableDataManager.SetReadOnlyMode(false);

        // [GIVEN] Two test records
        TestCode1 := CopyStr('DICT1-' + Format(CreateGuid()), 1, 20);
        TestCode2 := CopyStr('DICT2-' + Format(CreateGuid()), 1, 20);

        // [WHEN] Insert first record
        TableDataManager.OpenRecordReference(RecordReference);
        FieldReference := RecordReference.Field(1);
        FieldReference.Value := TestCode1;
        RecordWriter.InsertRecord(RecordReference, true, false);

        RowNumber := 1;
        TableDataManager.AddRecordId(RowNumber, RecordReference.RecordId);

        // [THEN] Should be able to retrieve the RecordId
        LibraryAssert.IsTrue(TableDataManager.GetRecordId(RowNumber, RetrievedRecordId), 'Should retrieve RecordId');
        LibraryAssert.AreEqual(Format(RecordReference.RecordId), Format(RetrievedRecordId), 'RecordId should match');

        // [WHEN] Insert second record and update the same row number
        RecordReference.Close();
        TableDataManager.OpenRecordReference(RecordReference);
        FieldReference := RecordReference.Field(1);
        FieldReference.Value := TestCode2;
        RecordWriter.InsertRecord(RecordReference, true, false);

        TableDataManager.UpdateRecordId(RowNumber, RecordReference.RecordId);

        // [THEN] Should retrieve the updated RecordId
        LibraryAssert.IsTrue(TableDataManager.GetRecordId(RowNumber, RetrievedRecordId), 'Should retrieve updated RecordId');
        LibraryAssert.AreEqual(Format(RecordReference.RecordId), Format(RetrievedRecordId), 'Updated RecordId should match');

        // [WHEN] Remove the RecordId from dictionary
        TableDataManager.RemoveRecordId(RowNumber);

        // [THEN] Should not be able to retrieve it
        Clear(RetrievedRecordId);
        LibraryAssert.IsFalse(TableDataManager.GetRecordId(RowNumber, RetrievedRecordId), 'Should not retrieve removed RecordId');
    end;

    #endregion
}
