namespace SamueleCelebron.ObjectLauncher;

using System.IO;
using System.Reflection;
using System.Text;
using System.Utilities;

/// <summary>
/// Stateful session context codeunit that owns all dictionaries, temporary records,
/// configuration flags, and column pagination for the Table Data Editor.
/// Handles record loading, field metadata, navigation, filter/sort/key management.
/// Does NOT perform database writes or field-type-specific logic.
/// </summary>
codeunit 50100 "Table Data Manager"
{
    #region Initialization

    /// <summary>
    /// Initializes the Table Data Manager with a table number and company name.
    /// Sets default configuration: ReadOnlyMode = true, ValidateFields = true, RunTriggers = true.
    /// </summary>
    /// <param name="NewTableNumber">The ID of the table to manage.</param>
    /// <param name="NewCompanyName">The company name for record access.</param>
    procedure Initialize(NewTableNumber: Integer; NewCompanyName: Text)
    begin
        TableNumber := NewTableNumber;
        TargetCompanyName := NewCompanyName;
        ReadOnlyMode := true;
        ValidateFields := true;
        RunTriggers := true;
        ColumnSetNumber := 0;
        RecordCount := 0;
        IsInitialized := true;
        Clear(RecordDictionary);
        Clear(FieldDictionary);
        Clear(PrimaryKeyFieldSet);
        Clear(FlowFieldSet);
        TempSelectedField.Reset();
        TempSelectedField.DeleteAll();
        TempKeys.Reset();
        TempKeys.DeleteAll();
        TempSelectedKey.Reset();
        TempSelectedKey.DeleteAll();
        TempTableFilter.Reset();
        TempTableFilter.DeleteAll();
        Clear(TableFiltersText);
    end;

    /// <summary>
    /// Sets the table number for the data manager.
    /// </summary>
    /// <param name="NewTableNumber">The new table number.</param>
    procedure SetTableNumber(NewTableNumber: Integer)
    begin
        TableNumber := NewTableNumber;
    end;

    /// <summary>
    /// Gets the current table number.
    /// </summary>
    /// <returns>The table number currently managed.</returns>
    procedure GetTableNumber(): Integer
    begin
        exit(TableNumber);
    end;

    /// <summary>
    /// Sets the target company name for cross-company data access.
    /// </summary>
    /// <param name="NewCompanyName">The company name to use.</param>
    procedure SetCompanyName(NewCompanyName: Text)
    begin
        TargetCompanyName := NewCompanyName;
    end;

    /// <summary>
    /// Gets the current target company name.
    /// </summary>
    /// <returns>The company name being used for data access.</returns>
    procedure GetCompanyName(): Text
    begin
        exit(TargetCompanyName);
    end;

    #endregion

    #region Configuration

    /// <summary>
    /// Sets whether field validation should be triggered during write operations.
    /// </summary>
    /// <param name="NewValue">True to validate fields, false to skip validation.</param>
    procedure SetValidateFields(NewValue: Boolean)
    begin
        ValidateFields := NewValue;
    end;

    /// <summary>
    /// Gets the current validate fields setting.
    /// </summary>
    /// <returns>True if field validation is enabled.</returns>
    procedure GetValidateFields(): Boolean
    begin
        exit(ValidateFields);
    end;

    /// <summary>
    /// Sets whether table triggers should fire during write operations.
    /// </summary>
    /// <param name="NewValue">True to run triggers, false to skip triggers.</param>
    procedure SetRunTriggers(NewValue: Boolean)
    begin
        RunTriggers := NewValue;
    end;

    /// <summary>
    /// Gets the current run triggers setting.
    /// </summary>
    /// <returns>True if table triggers will fire during writes.</returns>
    procedure GetRunTriggers(): Boolean
    begin
        exit(RunTriggers);
    end;

    /// <summary>
    /// Sets the read-only mode. When true, all write operations are blocked.
    /// </summary>
    /// <param name="NewValue">True to enable read-only mode, false to allow writes.</param>
    procedure SetReadOnlyMode(NewValue: Boolean)
    begin
        ReadOnlyMode := NewValue;
    end;

    /// <summary>
    /// Gets the current read-only mode setting.
    /// </summary>
    /// <returns>True if the manager is in read-only mode.</returns>
    procedure GetReadOnlyMode(): Boolean
    begin
        exit(ReadOnlyMode);
    end;

    #endregion

    #region Record Loading

    /// <summary>
    /// Loads the full record set from the database into a temporary Integer table and the internal record dictionary.
    /// Clears existing state and repopulates from the current table with active filters and sorting.
    /// Shows a progress dialog when record count exceeds the threshold.
    /// </summary>
    /// <param name="SourceRecord">The temporary Integer record used as the page source.</param>
    /// <returns>The number of records loaded.</returns>
    procedure LoadRecordSet(var SourceRecord: Record Integer temporary): Integer
    var
        RecordReference: RecordRef;
        ProgressDialog: Dialog;
        Index: Integer;
    begin
        SourceRecord.Reset();
        SourceRecord.DeleteAll();
        Clear(RecordDictionary);

        PrepareRecordReference(RecordReference);
        RecordCount := RecordReference.Count;

        if RecordCount > 0 then
            if RecordReference.FindSet() then begin
                if GuiAllowed and (RecordCount > GetProgressDialogThreshold()) then
                    ProgressDialog.Open(LoadingRecordsDialogLbl);

                repeat
                    Index += 1;
                    SourceRecord.Init();
                    SourceRecord.Number := Index;
                    SourceRecord.Insert();
                    RecordDictionary.Add(Index, RecordReference.RecordId);

                    if GuiAllowed and (RecordCount > GetProgressDialogThreshold()) then
                        if (Index mod 100 = 0) or (Index = RecordCount) then
                            ProgressDialog.Update(1, Round(Index / RecordCount * 10000, 1));
                until RecordReference.Next() = 0;

                if GuiAllowed and (RecordCount > GetProgressDialogThreshold()) then
                    ProgressDialog.Close();
            end;

        if SourceRecord.FindFirst() then;

        exit(RecordCount);
    end;

    /// <summary>
    /// Loads field captions for the current table into the caption arrays and populates the field dictionary.
    /// Respects field selection and skips obsolete/disabled fields.
    /// </summary>
    /// <param name="CaptionArray">Array to populate with field captions for the data columns.</param>
    /// <param name="KeyCaptionArray">Array to populate with primary key field captions.</param>
    procedure LoadFieldCaptions(var CaptionArray: array[500] of Text; var KeyCaptionArray: array[10] of Text)
    var
        FieldRecord: Record "Field";
        FieldIndex: Integer;
        KeyIndex: Integer;
    begin
        Clear(CaptionArray);
        Clear(FieldDictionary);
        Clear(KeyCaptionArray);
        Clear(PrimaryKeyFieldSet);
        Clear(FlowFieldSet);

        GetFilteredFieldRecord(FieldRecord);
        FieldRecord.SetLoadFields("No.", "Field Caption", Class, Enabled, IsPartOfPrimaryKey, ObsoleteState);
        if FieldRecord.FindSet() then
            repeat
                if not IsFieldSkipped(FieldRecord) then begin
                    FieldIndex += 1;
                    CaptionArray[FieldIndex] := FieldRecord."Field Caption";
                    FieldDictionary.Add(FieldIndex, FieldRecord."No.");

                    if FieldRecord.IsPartOfPrimaryKey then begin
                        PrimaryKeyFieldSet.Add(FieldRecord."No.", true);
                        KeyIndex += 1;
                        if KeyIndex <= GetMaxPrimaryKeyFields() then
                            KeyCaptionArray[KeyIndex] := FieldRecord."Field Caption";
                    end;

                    if FieldRecord.Class = FieldRecord.Class::FlowField then
                        FlowFieldSet.Add(FieldRecord."No.", true);
                end;
            until (FieldRecord.Next() = 0) or (FieldIndex = GetMaxFieldCount());
    end;

    /// <summary>
    /// Loads the field values for a specific row number into the value arrays.
    /// Opens a RecordRef for the row, reads all fields, and formats the values.
    /// FlowFields are calculated before reading.
    /// </summary>
    /// <param name="RowNumber">The row number to load values for.</param>
    /// <param name="ValueArray">Array to populate with formatted field values.</param>
    /// <param name="KeyValueArray">Array to populate with formatted primary key values.</param>
    procedure LoadRecordValues(RowNumber: Integer; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        FieldNumber: Integer;
        FieldIndex: Integer;
        KeyIndex: Integer;
    begin
        Clear(ValueArray);
        Clear(KeyValueArray);

        if not GetRecordReference(RowNumber, RecordReference) then
            exit;

        for FieldIndex := 1 to FieldDictionary.Count do begin
            FieldDictionary.Get(FieldIndex, FieldNumber);
            FieldReference := RecordReference.Field(FieldNumber);

            if FlowFieldSet.ContainsKey(FieldNumber) then
                FieldReference.CalcField();

            ValueArray[FieldIndex] := Format(FieldReference.Value);

            if PrimaryKeyFieldSet.ContainsKey(FieldNumber) then begin
                KeyIndex += 1;
                if KeyIndex <= GetMaxPrimaryKeyFields() then
                    KeyValueArray[KeyIndex] := Format(FieldReference.Value);
            end;
        end;
    end;

    #endregion

    #region RecordRef Access

    /// <summary>
    /// Opens and positions a RecordRef for the given row number using the record dictionary.
    /// </summary>
    /// <param name="RowNumber">The row number to look up in the dictionary.</param>
    /// <param name="RecordReference">The RecordRef to open and position.</param>
    /// <returns>True if the record was found and positioned successfully.</returns>
    procedure GetRecordReference(RowNumber: Integer; var RecordReference: RecordRef): Boolean
    var
        RecordIdValue: RecordId;
    begin
        OpenRecordReference(RecordReference);

        if not RecordDictionary.Get(RowNumber, RecordIdValue) then
            exit(false);

        exit(RecordReference.Get(RecordIdValue));
    end;

    /// <summary>
    /// Opens a RecordRef on the current table and company without any filters or key.
    /// </summary>
    /// <param name="RecordReference">The RecordRef to open.</param>
    procedure OpenRecordReference(var RecordReference: RecordRef)
    begin
        RecordReference.Open(TableNumber, false, TargetCompanyName);
    end;

    /// <summary>
    /// Opens a RecordRef and applies the current filters and sorting key.
    /// </summary>
    /// <param name="RecordReference">The RecordRef to prepare.</param>
    procedure PrepareRecordReference(var RecordReference: RecordRef)
    begin
        OpenRecordReference(RecordReference);
        SetFiltersOnRecordReference(RecordReference);
        SetKeyOnRecordReference(RecordReference);
    end;

    #endregion

    #region Dictionary Access

    /// <summary>
    /// Gets the field number for a given column index from the field dictionary.
    /// </summary>
    /// <param name="ColumnIndex">The column index (1-based) in the field dictionary.</param>
    /// <returns>The field number corresponding to the column index.</returns>
    procedure GetFieldNumber(ColumnIndex: Integer): Integer
    var
        FieldNumber: Integer;
    begin
        FieldDictionary.Get(ColumnIndex, FieldNumber);
        exit(FieldNumber);
    end;

    /// <summary>
    /// Retrieves the RecordId for a given row number from the record dictionary.
    /// </summary>
    /// <param name="RowNumber">The row number to look up.</param>
    /// <param name="RecordIdOut">The RecordId if found.</param>
    /// <returns>True if the row number exists in the dictionary.</returns>
    procedure GetRecordId(RowNumber: Integer; var RecordIdOut: RecordId): Boolean
    begin
        exit(RecordDictionary.Get(RowNumber, RecordIdOut));
    end;

    /// <summary>
    /// Adds a new RecordId to the record dictionary for a given row number.
    /// </summary>
    /// <param name="RowNumber">The row number to add.</param>
    /// <param name="NewRecordId">The RecordId to associate with the row.</param>
    procedure AddRecordId(RowNumber: Integer; NewRecordId: RecordId)
    begin
        RecordDictionary.Add(RowNumber, NewRecordId);
    end;

    /// <summary>
    /// Updates the RecordId for an existing row number in the record dictionary.
    /// Used after rename operations that change the record's identity.
    /// </summary>
    /// <param name="RowNumber">The row number to update.</param>
    /// <param name="NewRecordId">The new RecordId to associate.</param>
    procedure UpdateRecordId(RowNumber: Integer; NewRecordId: RecordId)
    begin
        RecordDictionary.Set(RowNumber, NewRecordId);
    end;

    /// <summary>
    /// Removes a row number and its RecordId from the record dictionary.
    /// </summary>
    /// <param name="RowNumber">The row number to remove.</param>
    procedure RemoveRecordId(RowNumber: Integer)
    begin
        RecordDictionary.Remove(RowNumber);
    end;

    #endregion

    #region Column Navigation

    /// <summary>
    /// Calculates the absolute column index for a position within the current column set.
    /// Combines the current page offset with the position within that page.
    /// </summary>
    /// <param name="ColumnPosition">The position within the current column set (1-10).</param>
    /// <returns>The absolute column index in the field array.</returns>
    procedure GetControlSetNumber(ColumnPosition: Integer): Integer
    begin
        exit((ColumnSetNumber * GetColumnsPerPage()) + ColumnPosition);
    end;

    /// <summary>
    /// Advances to the next column set if more columns are available.
    /// </summary>
    /// <param name="CaptionArray">The caption array used to check if the next set has data.</param>
    /// <returns>True if the move succeeded, false if already at the last set.</returns>
    procedure MoveToNextColumnSet(var CaptionArray: array[500] of Text): Boolean
    begin
        ColumnSetNumber += 1;
        if CaptionArray[GetControlSetNumber(1)] = '' then begin
            ColumnSetNumber -= 1;
            exit(false);
        end;
        exit(true);
    end;

    /// <summary>
    /// Moves back to the previous column set if not already at the first set.
    /// </summary>
    /// <returns>True if the move succeeded, false if already at set 0.</returns>
    procedure MoveToPreviousColumnSet(): Boolean
    begin
        if (ColumnSetNumber - 1) < 0 then
            exit(false);

        ColumnSetNumber -= 1;
        exit(true);
    end;

    /// <summary>
    /// Resets column navigation to the first column set (position 0).
    /// </summary>
    procedure MoveToFirstColumnSet()
    begin
        ColumnSetNumber := 0;
    end;

    /// <summary>
    /// Advances column navigation to the last column set based on the total field count.
    /// </summary>
    procedure MoveToLastColumnSet()
    var
        FieldRecord: Record "Field";
    begin
        GetFilteredFieldRecord(FieldRecord);
        FieldRecord.SetLoadFields("No.");
        ColumnSetNumber := FieldRecord.Count div GetColumnsPerPage();
    end;

    #endregion

    #region Filters and Sorting

    /// <summary>
    /// Opens the Table Filter dialog page and applies the selected filters.
    /// Reloads the record set after filters are applied.
    /// </summary>
    /// <param name="SourceRecord">The temporary Integer record to reload after filtering.</param>
    procedure OpenFilterDialog(var SourceRecord: Record Integer temporary)
    var
        TableFilterPage: Page "Table Filter";
    begin
        TableFilterPage.SetSourceTable(TableFiltersText, TableNumber, '');
        TableFilterPage.RunModal();
        TableFilterPage.GetFilterFieldsList(TempTableFilter);
        TableFiltersText := TableFilterPage.CreateTextTableFilter(false);
        LoadRecordSet(SourceRecord);
    end;

    /// <summary>
    /// Applies the stored table filters to a RecordRef using field references.
    /// </summary>
    /// <param name="RecordReference">The RecordRef to apply filters to.</param>
    procedure SetFiltersOnRecordReference(var RecordReference: RecordRef)
    var
        FieldReference: FieldRef;
    begin
        if TempTableFilter.FindSet() then
            repeat
                FieldReference := RecordReference.Field(TempTableFilter."Field Number");
                FieldReference.SetFilter(TempTableFilter."Field Filter");
            until TempTableFilter.Next() = 0;
    end;

    /// <summary>
    /// Clears all filters, field selections, key selections, and column navigation.
    /// Reloads captions and records from scratch.
    /// </summary>
    /// <param name="CaptionArray">The caption array to reload.</param>
    /// <param name="KeyCaptionArray">The key caption array to reload.</param>
    /// <param name="SourceRecord">The temporary Integer record to reload.</param>
    procedure ClearAllFilters(var CaptionArray: array[500] of Text; var KeyCaptionArray: array[10] of Text; var SourceRecord: Record Integer temporary)
    begin
        TempTableFilter.Reset();
        TempTableFilter.DeleteAll();
        Clear(TableFiltersText);
        TempSelectedField.Reset();
        TempSelectedField.DeleteAll();
        TempSelectedKey.Reset();
        TempSelectedKey.DeleteAll();
        ColumnSetNumber := 0;
        LoadFieldCaptions(CaptionArray, KeyCaptionArray);
        LoadRecordSet(SourceRecord);
    end;

    /// <summary>
    /// Configures a Field record variable with filters for the current table,
    /// excluding obsolete (removed) and disabled fields.
    /// </summary>
    /// <param name="FieldRecord">The Field record to configure with filters.</param>
    procedure GetFilteredFieldRecord(var FieldRecord: Record Field)
    begin
        FieldRecord.SetRange(TableNo, TableNumber);
        FieldRecord.SetFilter(ObsoleteState, '<>%1', FieldRecord.ObsoleteState::Removed);
        FieldRecord.SetRange(Enabled, true);
    end;

    /// <summary>
    /// Determines whether a field should be skipped during caption/value loading.
    /// When a field selection is active, only selected fields and primary key fields are included.
    /// Primary key fields are never skipped.
    /// </summary>
    /// <param name="FieldRecord">The field to check.</param>
    /// <returns>True if the field should be skipped, false if it should be included.</returns>
    procedure IsFieldSkipped(var FieldRecord: Record Field): Boolean
    begin
        TempSelectedField.Reset();
        if TempSelectedField.IsEmpty then
            exit(false);

        if FieldRecord.IsPartOfPrimaryKey then
            exit(false);

        TempSelectedField.SetRange("No.", FieldRecord."No.");
        exit(TempSelectedField.IsEmpty);
    end;

    #endregion

    #region Field Selection and Key Selection

    /// <summary>
    /// Opens the Fields Lookup page for the user to select which fields to display.
    /// Primary key fields are always included regardless of selection.
    /// Reloads captions after selection.
    /// </summary>
    /// <param name="CaptionArray">The caption array to reload after selection.</param>
    /// <param name="KeyCaptionArray">The key caption array to reload after selection.</param>
    procedure OpenFieldSelection(var CaptionArray: array[500] of Text; var KeyCaptionArray: array[10] of Text)
    var
        FieldRecord: Record "Field";
        FieldsLookup: Page "Fields Lookup";
        UserAction: Action;
    begin
        GetFilteredFieldRecord(FieldRecord);
        FieldsLookup.SetTableView(FieldRecord);
        FieldsLookup.LookupMode(true);
        UserAction := FieldsLookup.RunModal();
        if not (UserAction in [Action::OK, Action::LookupOK]) then
            exit;

        FieldsLookup.SetSelectionFilter(FieldRecord);
        FieldRecord.SetRange(IsPartOfPrimaryKey, false);
        if FieldRecord.FindSet() then
            repeat
                TempSelectedField := FieldRecord;
                if TempSelectedField.Insert() then;
            until FieldRecord.Next() = 0;

        LoadFieldCaptions(CaptionArray, KeyCaptionArray);
    end;

    /// <summary>
    /// Opens the Sorting Keys page for the user to select a sorting key.
    /// Reloads the record set after a key is selected.
    /// </summary>
    /// <param name="SourceRecord">The temporary Integer record to reload after key change.</param>
    procedure SelectSortingKey(var SourceRecord: Record Integer temporary)
    var
        SortingKeysPage: Page "Sorting keys";
        UserAction: Action;
    begin
        if TempSelectedKey.Delete() then;

        SortingKeysPage.SetTableNo(TableNumber, TempKeys);
        SortingKeysPage.LookupMode := true;
        UserAction := SortingKeysPage.RunModal();
        if not (UserAction in [Action::OK, Action::LookupOK]) then
            exit;

        SortingKeysPage.GetTempKey(TempKeys);
        SortingKeysPage.GetSelectedRec(TempSelectedKey);
        LoadRecordSet(SourceRecord);
    end;

    /// <summary>
    /// Applies the selected sorting key to a RecordRef using the Type Helper.
    /// </summary>
    /// <param name="RecordReference">The RecordRef to apply sorting to.</param>
    procedure SetKeyOnRecordReference(var RecordReference: RecordRef)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if TempSelectedKey.IsEmpty then
            exit;

        TempSelectedKey.FindFirst();
        TypeHelper.SortRecordRef(RecordReference, TempSelectedKey."Key", not TempSelectedKey.Unique);
    end;

    #endregion

    #region Display Helpers

    /// <summary>
    /// Gets the caption of the current table from AllObjWithCaption.
    /// </summary>
    /// <returns>The table caption, or empty string if not found.</returns>
    procedure GetTableCaption(): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetLoadFields("Object Caption");
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::TableData, TableNumber) then
            exit(AllObjWithCaption."Object Caption");
    end;

    /// <summary>
    /// Opens the card page for a specific row's record.
    /// Uses Config. Management to find the appropriate page, then falls back to the default page.
    /// </summary>
    /// <param name="RowNumber">The row number of the record to open.</param>
    procedure OpenPageForRecord(RowNumber: Integer)
    var
        PageMetadata: Record "Page Metadata";
        ConfigManagement: Codeunit "Config. Management";
        RecordReference: RecordRef;
        PageId: Integer;
        VariantRecord: Variant;
    begin
        if not GetRecordReference(RowNumber, RecordReference) then
            Error(RecordNotFoundErr, RowNumber);

        VariantRecord := RecordReference;
        PageId := ConfigManagement.FindPage(TableNumber);
        if PageMetadata.Get(PageId) and (PageMetadata.CardPageID <> 0) then
            Page.RunModal(PageMetadata.CardPageID, VariantRecord)
        else
            Page.RunModal(0, VariantRecord);
    end;

    /// <summary>
    /// Recounts the total records matching the current filters.
    /// </summary>
    procedure CountRecords()
    var
        RecordReference: RecordRef;
    begin
        PrepareRecordReference(RecordReference);
        RecordCount := RecordReference.Count;
    end;

    /// <summary>
    /// Gets the current record count.
    /// </summary>
    /// <returns>The number of records matching the current filters.</returns>
    procedure GetRecordCount(): Integer
    begin
        exit(RecordCount);
    end;

    /// <summary>
    /// Determines whether the current table is a sensitive posted/ledger table
    /// where direct modifications may cause data inconsistencies.
    /// </summary>
    /// <returns>True if the table is in the sensitive table list.</returns>
    procedure IsSensitiveTable(): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ObjectName: Text;
    begin
        // Explicit critical tables
        if TableNumber in [
            17,   // G/L Entry
            21,   // Cust. Ledger Entry
            25,   // Vendor Ledger Entry
            32,   // Item Ledger Entry
            112,  // Sales Invoice Header
            113,  // Sales Invoice Line
            114,  // Sales Cr.Memo Header
            120,  // Purch. Rcpt. Header
            122,  // Purch. Inv. Header
            254,  // VAT Entry
            271,  // Bank Account Ledger Entry
            339,  // Check Ledger Entry
            379,  // Detailed Cust. Ledg. Entry
            380,  // Detailed Vendor Ledg. Entry
            5601, // FA Ledger Entry
            5802  // Value Entry
        ] then
            exit(true);

        // Pattern-based detection for other posted/ledger tables
        AllObjWithCaption.SetLoadFields("Object Name");
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::TableData, TableNumber) then begin
            ObjectName := AllObjWithCaption."Object Name";
            if ObjectName.Contains('Ledger Entry') or
               ObjectName.Contains('Register') or
               ObjectName.Contains('Posted ')
            then
                exit(true);
        end;

        exit(false);
    end;

    #endregion

    #region Named Constants

    /// <summary>
    /// Returns the maximum number of data fields supported (array size).
    /// </summary>
    /// <returns>500</returns>
    procedure GetMaxFieldCount(): Integer
    begin
        exit(500);
    end;

    /// <summary>
    /// Returns the number of columns displayed per page set.
    /// </summary>
    /// <returns>10</returns>
    procedure GetColumnsPerPage(): Integer
    begin
        exit(10);
    end;

    /// <summary>
    /// Returns the maximum number of primary key fields supported.
    /// </summary>
    /// <returns>5</returns>
    procedure GetMaxPrimaryKeyFields(): Integer
    begin
        exit(5);
    end;

    /// <summary>
    /// Returns the record count threshold above which a progress dialog is shown.
    /// </summary>
    /// <returns>100</returns>
    local procedure GetProgressDialogThreshold(): Integer
    begin
        exit(100);
    end;

    #endregion

    var
        TempSelectedField: Record Field temporary;
        TempKeys: Record "Key" temporary;
        TempSelectedKey: Record "Key" temporary;
        TempTableFilter: Record "Table Filter" temporary;
        RecordDictionary: Dictionary of [Integer, RecordId];
        FieldDictionary: Dictionary of [Integer, Integer];
        PrimaryKeyFieldSet: Dictionary of [Integer, Boolean];
        FlowFieldSet: Dictionary of [Integer, Boolean];
        TableFiltersText: Text;
        TargetCompanyName: Text;
        ColumnSetNumber: Integer;
        RecordCount: Integer;
        TableNumber: Integer;
        IsInitialized: Boolean;
        ReadOnlyMode: Boolean;
        RunTriggers: Boolean;
        ValidateFields: Boolean;

        LoadingRecordsDialogLbl: Label 'Loading records... @1@@@@@@@@@@';
        RecordNotFoundErr: Label 'Record not found for row number %1.', Comment = '%1 = Row number';
}
