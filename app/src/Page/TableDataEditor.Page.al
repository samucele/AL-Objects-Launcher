namespace SamueleCelebron.ObjectLauncher;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Environment;
using System.Reflection;
using System.Utilities;

page 50102 "Table Data Editor"
{
    ApplicationArea = All;
    Caption = 'Table Data Editor';
    PageType = List;
    Permissions =
        tabledata "Sales Invoice Header" = rimd,
        tabledata "Sales Invoice Line" = rimd,
        tabledata "Sales Cr.Memo Header" = rimd,
        tabledata "Sales Cr.Memo Line" = rimd,
        tabledata "Sales Shipment Header" = rimd,
        tabledata "Sales Shipment Line" = rimd,
        tabledata "Purch. Rcpt. Header" = rimd,
        tabledata "Purch. Rcpt. Line" = rimd,
        tabledata "Purch. Inv. Header" = rimd,
        tabledata "Purch. Inv. Line" = rimd,
        tabledata "Purch. Cr. Memo Hdr." = rimd,
        tabledata "Purch. Cr. Memo Line" = rimd,
        tabledata "G/L Entry" = rimd,
        tabledata "Cust. Ledger Entry" = rimd,
        tabledata "Vendor Ledger Entry" = rimd,
        tabledata "G/L Register" = rimd,
        tabledata "G/L Entry - VAT Entry Link" = rimd,
        tabledata "VAT Entry" = rimd,
        tabledata "Detailed Cust. Ledg. Entry" = rimd,
        tabledata "Detailed Vendor Ledg. Entry" = rimd,
        tabledata "CV Ledger Entry Buffer" = rimd,
        tabledata "Detailed CV Ledg. Entry Buffer" = rimd,
        tabledata "Post Value Entry to G/L" = rimd,
        tabledata "G/L - Item Ledger Relation" = rimd,
        tabledata "Item Ledger Entry" = rimd,
        tabledata "Value Entry" = rimd;
    SourceTable = Integer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            // #region Parameters
            group(Parameters)
            {
                field(TableNumber; TableNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(TableData));
                    ToolTip = 'Enter or select the ID of the table to browse. Changing the table reloads all data, captions, and resets filters.';
                    trigger OnValidate()
                    begin
                        TableDataManager.SetTableNumber(TableNumber);
                        TableDataManager.ClearAllFilters(CaptionData, KeyCaptionData, Rec);
                        RecordCount := TableDataManager.GetRecordCount();
                        CurrPage.Update(false);
                    end;
                }
                field(TableCaption; TableDataManager.GetTableCaption())
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    Editable = false;
                    ToolTip = 'Shows the caption of the currently loaded table as defined in the AL table object.';
                }
                field(RecordCountField; RecordCount)
                {
                    ApplicationArea = All;
                    Caption = 'Record Count';
                    Editable = false;
                    ToolTip = 'Shows the total number of records currently loaded, accounting for any active filters.';
                }
                field(TargetCompanyName; TargetCompanyName)
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                    TableRelation = Company;
                    ToolTip = 'Select the company whose data should be displayed. Defaults to the current company. Changing this reloads all records from the selected company.';
                    trigger OnValidate()
                    begin
                        if TargetCompanyName = '' then
                            TargetCompanyName := Rec.CurrentCompany;

                        TableDataManager.SetCompanyName(TargetCompanyName);
                        RecordCount := TableDataManager.LoadRecordSet(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(ValidateFields; ValidateFields)
                {
                    ApplicationArea = All;
                    Caption = 'Validate';
                    ToolTip = 'When enabled, field validation triggers are executed on value changes, enforcing business rules. Disable to bypass validation for direct data manipulation.';
                    trigger OnValidate()
                    begin
                        TableDataManager.SetValidateFields(ValidateFields);
                        CurrPage.Update();
                    end;
                }
                field(RunTriggers; RunTriggers)
                {
                    ApplicationArea = All;
                    Caption = 'Run Triggers';
                    ToolTip = 'When enabled, table triggers (OnInsert, OnModify, OnDelete) are executed during write operations. Disable to bypass trigger logic for bulk or recovery operations.';
                    trigger OnValidate()
                    begin
                        TableDataManager.SetRunTriggers(RunTriggers);
                        CurrPage.Update();
                    end;
                }
                field(EditModeIndicator; EditModeDisplayText)
                {
                    ApplicationArea = All;
                    Caption = 'Mode';
                    Editable = false;
                    StyleExpr = EditModeStyleExpression;
                    ToolTip = 'Shows the current operating mode. READ-ONLY prevents any data modifications. EDIT MODE allows data changes with the configured validation and trigger settings.';
                }
            }
            // #endregion Parameters

            // #region Repeater
            repeater(DataRepeater)
            {
                // #region Key Fields
                field(KeyMatrixData1; KeyMatrixData[1])
                {
                    ApplicationArea = All;
                    CaptionClass = KeyCaptionData[1];
                    Editable = false;
                    ToolTip = 'Shows the value of the first primary key field for quick identification. Primary key fields are always read-only in the repeater.';
                    Visible = KeyControlVisibility1;
                }
                field(KeyMatrixData2; KeyMatrixData[2])
                {
                    ApplicationArea = All;
                    CaptionClass = KeyCaptionData[2];
                    Editable = false;
                    ToolTip = 'Shows the value of the second primary key field for quick identification. Primary key fields are always read-only in the repeater.';
                    Visible = KeyControlVisibility2;
                }
                field(KeyMatrixData3; KeyMatrixData[3])
                {
                    ApplicationArea = All;
                    CaptionClass = KeyCaptionData[3];
                    Editable = false;
                    ToolTip = 'Shows the value of the third primary key field for quick identification. Primary key fields are always read-only in the repeater.';
                    Visible = KeyControlVisibility3;
                }
                field(KeyMatrixData4; KeyMatrixData[4])
                {
                    ApplicationArea = All;
                    CaptionClass = KeyCaptionData[4];
                    Editable = false;
                    ToolTip = 'Shows the value of the fourth primary key field for quick identification. Primary key fields are always read-only in the repeater.';
                    Visible = KeyControlVisibility4;
                }
                field(KeyMatrixData5; KeyMatrixData[5])
                {
                    ApplicationArea = All;
                    CaptionClass = KeyCaptionData[5];
                    Editable = false;
                    ToolTip = 'Shows the value of the fifth primary key field for quick identification. Primary key fields are always read-only in the repeater.';
                    Visible = KeyControlVisibility5;
                }
                // #endregion Key Fields

                // #region Matrix Data Fields
                field(MatrixData1; MatrixData[GetControlSetNumber(1)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(1)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility1;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(1), MatrixData[GetControlSetNumber(1)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(1), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData2; MatrixData[GetControlSetNumber(2)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(2)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility2;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(2), MatrixData[GetControlSetNumber(2)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(2), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData3; MatrixData[GetControlSetNumber(3)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(3)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility3;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(3), MatrixData[GetControlSetNumber(3)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(3), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData4; MatrixData[GetControlSetNumber(4)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(4)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility4;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(4), MatrixData[GetControlSetNumber(4)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(4), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData5; MatrixData[GetControlSetNumber(5)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(5)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility5;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(5), MatrixData[GetControlSetNumber(5)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(5), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData6; MatrixData[GetControlSetNumber(6)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(6)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility6;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(6), MatrixData[GetControlSetNumber(6)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(6), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData7; MatrixData[GetControlSetNumber(7)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(7)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility7;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(7), MatrixData[GetControlSetNumber(7)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(7), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData8; MatrixData[GetControlSetNumber(8)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(8)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility8;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(8), MatrixData[GetControlSetNumber(8)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(8), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData9; MatrixData[GetControlSetNumber(9)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(9)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility9;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(9), MatrixData[GetControlSetNumber(9)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(9), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                field(MatrixData10; MatrixData[GetControlSetNumber(10)])
                {
                    ApplicationArea = All;
                    CaptionClass = CaptionData[GetControlSetNumber(10)];
                    Editable = EditModeEnabled;
                    ToolTip = 'Shows and allows editing of the field value for this column. The column caption indicates which table field is displayed. Use the lookup to select from valid values.';
                    Visible = MatrixDataVisibility10;
                    trigger OnValidate()
                    begin
                        FieldValueHandler.WriteFieldValue(TableDataManager, Rec.Number, GetControlSetNumber(10), MatrixData[GetControlSetNumber(10)], MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldValueHandler.PerformFieldLookup(TableDataManager, Rec.Number, GetControlSetNumber(10), MatrixData, KeyMatrixData);
                        RecordCount := TableDataManager.GetRecordCount();
                    end;
                }
                // #endregion Matrix Data Fields
            }
            // #endregion Repeater
        }
    }

    actions
    {
        // #region Processing Actions
        area(Processing)
        {
            // #region Navigate Group
            group(NavigationActions)
            {
                Caption = 'Navigate';

                action(FirstSet)
                {
                    ApplicationArea = All;
                    Caption = 'First Set';
                    Image = PreviousSet;
                    ShortcutKey = 'Ctrl+Home';
                    ToolTip = 'Navigates to the first set of 10 columns, showing the leftmost fields in the table definition.';
                    trigger OnAction()
                    begin
                        TableDataManager.MoveToFirstColumnSet();
                        CurrPage.Update();
                    end;
                }
                action(PreviousSet)
                {
                    ApplicationArea = All;
                    Caption = 'Previous Set';
                    Image = PreviousRecord;
                    ShortcutKey = 'Ctrl+Left';
                    ToolTip = 'Navigates to the previous set of 10 columns. Does nothing if already at the first column set.';
                    trigger OnAction()
                    begin
                        TableDataManager.MoveToPreviousColumnSet();
                        CurrPage.Update();
                    end;
                }
                action(NextSet)
                {
                    ApplicationArea = All;
                    Caption = 'Next Set';
                    Image = NextRecord;
                    ShortcutKey = 'Ctrl+Right';
                    ToolTip = 'Navigates to the next set of 10 columns. Does nothing if there are no more fields beyond the current set.';
                    trigger OnAction()
                    begin
                        TableDataManager.MoveToNextColumnSet(CaptionData);
                        CurrPage.Update();
                    end;
                }
                action(LastSet)
                {
                    ApplicationArea = All;
                    Caption = 'Last Set';
                    Image = NextSet;
                    ShortcutKey = 'Ctrl+End';
                    ToolTip = 'Navigates to the last set of 10 columns, showing the rightmost fields in the table definition.';
                    trigger OnAction()
                    begin
                        TableDataManager.MoveToLastColumnSet();
                        CurrPage.Update();
                    end;
                }
                action(FieldsSelection)
                {
                    ApplicationArea = All;
                    Caption = 'Fields Selection';
                    Image = SelectField;
                    ShortcutKey = 'Ctrl+L';
                    ToolTip = 'Opens a dialog to select which fields are displayed as columns. Primary key fields are always shown regardless of selection.';
                    trigger OnAction()
                    begin
                        TableDataManager.OpenFieldSelection(CaptionData, KeyCaptionData);
                        CurrPage.Update(false);
                    end;
                }
                action(OpenRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Open Record';
                    Image = ViewPage;
                    Scope = Repeater;
                    ToolTip = 'Opens the selected record in its associated card page for viewing or editing with full page functionality.';
                    trigger OnAction()
                    begin
                        TableDataManager.OpenPageForRecord(Rec.Number);
                        TableDataManager.LoadRecordValues(Rec.Number, MatrixData, KeyMatrixData);
                    end;
                }
            }
            // #endregion Navigate Group

            // #region View Group
            group(ViewActions)
            {
                Caption = 'View';

                action(TableFilters)
                {
                    ApplicationArea = All;
                    Caption = 'Table Filters';
                    Image = EditFilter;
                    ShortcutKey = 'Ctrl+F';
                    ToolTip = 'Opens the filter dialog to define field-level filters that restrict which records are loaded from the database.';
                    trigger OnAction()
                    begin
                        TableDataManager.OpenFilterDialog(Rec);
                        RecordCount := TableDataManager.GetRecordCount();
                        CurrPage.Update(false);
                    end;
                }
                action(SelectSortingKey)
                {
                    ApplicationArea = All;
                    Caption = 'Select Sorting Key';
                    Image = EncryptionKeys;
                    ToolTip = 'Opens the sorting key selection page to choose an alternative key for record ordering. Records are reloaded in the new sort order.';
                    trigger OnAction()
                    begin
                        TableDataManager.SelectSortingKey(Rec);
                        RecordCount := TableDataManager.GetRecordCount();
                        CurrPage.Update(false);
                    end;
                }
                action(ResetPage)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Page';
                    Image = ClearFilter;
                    ToolTip = 'Clears all active filters, field selections, and sorting keys, then reloads all records with default settings.';
                    trigger OnAction()
                    begin
                        TableDataManager.ClearAllFilters(CaptionData, KeyCaptionData, Rec);
                        RecordCount := TableDataManager.GetRecordCount();
                        CurrPage.Update(false);
                    end;
                }
                action(ToggleEditMode)
                {
                    ApplicationArea = All;
                    Caption = 'Toggle Edit Mode';
                    Image = Edit;
                    ShortcutKey = 'Ctrl+E';
                    ToolTip = 'Switches between read-only and edit mode. In read-only mode all data modifications are prevented. Edit mode enables field editing, record deletion, and other write operations.';
                    trigger OnAction()
                    begin
                        ToggleEditModeAction();
                    end;
                }
            }
            // #endregion View Group

            // #region Data Group
            group(DataActions)
            {
                Caption = 'Data';
                Visible = EditModeEnabled;

                action(DeleteAllRecords)
                {
                    ApplicationArea = All;
                    Caption = 'Delete All';
                    Image = DeleteAllBreakpoints;
                    ToolTip = 'Deletes all records matching the current filters after confirmation. This operation cannot be undone. Only available in edit mode.';
                    trigger OnAction()
                    var
                        RecordReference: RecordRef;
                    begin
                        TableDataManager.PrepareRecordReference(RecordReference);
                        if RecordWriter.DeleteAllRecords(RecordReference, TableDataManager.GetRunTriggers(), TableDataManager.GetReadOnlyMode()) then begin
                            TableDataManager.ClearAllFilters(CaptionData, KeyCaptionData, Rec);
                            RecordCount := TableDataManager.GetRecordCount();
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            // #endregion Data Group

            // #region Export Group
            group(ExportActions)
            {
                Caption = 'Export';

                action(ExportToExcel)
                {
                    ApplicationArea = All;
                    Caption = 'Export to Excel';
                    Image = ExportToExcel;
                    ShortcutKey = 'Ctrl+Shift+E';
                    ToolTip = 'Exports all loaded records to an Excel spreadsheet. Column headers match the displayed field captions, and cell types are matched to AL field types (number, date, text).';
                    trigger OnAction()
                    begin
                        DataExportManager.ExportTableToExcel(TableDataManager);
                    end;
                }
            }
            // #endregion Export Group
        }
        // #endregion Processing Actions

        // #region Promoted Actions
        area(Promoted)
        {
            group(Category_Navigation)
            {
                Caption = 'Navigate';

                actionref(FirstSet_Promoted; FirstSet)
                {
                }
                actionref(PreviousSet_Promoted; PreviousSet)
                {
                }
                actionref(NextSet_Promoted; NextSet)
                {
                }
                actionref(LastSet_Promoted; LastSet)
                {
                }
            }
            group(Category_View)
            {
                Caption = 'View';

                actionref(TableFilters_Promoted; TableFilters)
                {
                }
                actionref(FieldsSelection_Promoted; FieldsSelection)
                {
                }
                actionref(SelectSortingKey_Promoted; SelectSortingKey)
                {
                }
                actionref(ToggleEditMode_Promoted; ToggleEditMode)
                {
                }
            }
            group(Category_Data)
            {
                Caption = 'Data';

                actionref(DeleteAllRecords_Promoted; DeleteAllRecords)
                {
                }
            }
            group(Category_Export)
            {
                Caption = 'Export';

                actionref(ExportToExcel_Promoted; ExportToExcel)
                {
                }
            }
        }
        // #endregion Promoted Actions
    }

    // #region Page Triggers
    trigger OnOpenPage()
    begin
        TargetCompanyName := Rec.CurrentCompany;
        ValidateFields := true;
        RunTriggers := true;
        EditModeEnabled := false;

        TableDataManager.Initialize(TableNumber, TargetCompanyName);
        TableDataManager.SetValidateFields(ValidateFields);
        TableDataManager.SetRunTriggers(RunTriggers);
        TableDataManager.LoadFieldCaptions(CaptionData, KeyCaptionData);
        RecordCount := TableDataManager.LoadRecordSet(Rec);

        UpdateEditModeDisplay();
        SetKeyControlVisibility();
        SetMatrixDataVisibility();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(MatrixData);
        Clear(KeyMatrixData);
        Rec.Number := RecordCount + 1;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        RecordReference: RecordRef;
    begin
        TableDataManager.GetRecordReference(Rec.Number, RecordReference);
        RecordWriter.DeleteRecord(RecordReference, TableDataManager.GetRunTriggers(), TableDataManager.GetReadOnlyMode());
        TableDataManager.RemoveRecordId(Rec.Number);
        TableDataManager.CountRecords();
        RecordCount := TableDataManager.GetRecordCount();
        Clear(MatrixData);
        Clear(KeyMatrixData);
        CurrPage.Update();
    end;

    trigger OnAfterGetRecord()
    begin
        TableDataManager.LoadRecordValues(Rec.Number, MatrixData, KeyMatrixData);
        SetKeyControlVisibility();
        SetMatrixDataVisibility();
    end;
    // #endregion Page Triggers

    // #region Public API

    /// <summary>
    /// Sets the table number to load when the page opens.
    /// Called by the AL Objects Launcher page before RunModal.
    /// </summary>
    /// <param name="NewTableNumber">The ID of the table to browse.</param>
    procedure SetTableNumber(NewTableNumber: Integer)
    begin
        TableNumber := NewTableNumber;
    end;

    /// <summary>
    /// Opens the filter dialog before or after page load.
    /// Called by the AL Objects Launcher when opening a table with filters.
    /// </summary>
    /// <param name="LoadRecordsAfter">If true, records are reloaded after setting filters.</param>
    procedure OpenFilterDialog(LoadRecordsAfter: Boolean)
    begin
        TableDataManager.OpenFilterDialog(Rec);
        if LoadRecordsAfter then begin
            RecordCount := TableDataManager.GetRecordCount();
            CurrPage.Update(false);
        end;
    end;
    // #endregion Public API

    // #region Local UI Helpers

    local procedure GetControlSetNumber(ColumnPosition: Integer): Integer
    begin
        exit(TableDataManager.GetControlSetNumber(ColumnPosition));
    end;

    local procedure SetKeyControlVisibility()
    var
        ColumnSetNumber: Integer;
    begin
        ColumnSetNumber := TableDataManager.GetControlSetNumber(1) - 1;
        KeyControlVisibility1 := ColumnSetNumber > 0;
        KeyControlVisibility2 := (ColumnSetNumber > 0) and (KeyCaptionData[2] <> '');
        KeyControlVisibility3 := (ColumnSetNumber > 0) and (KeyCaptionData[3] <> '');
        KeyControlVisibility4 := (ColumnSetNumber > 0) and (KeyCaptionData[4] <> '');
        KeyControlVisibility5 := (ColumnSetNumber > 0) and (KeyCaptionData[5] <> '');
    end;

    local procedure SetMatrixDataVisibility()
    begin
        MatrixDataVisibility1 := CaptionData[GetControlSetNumber(1)] <> '';
        MatrixDataVisibility2 := CaptionData[GetControlSetNumber(2)] <> '';
        MatrixDataVisibility3 := CaptionData[GetControlSetNumber(3)] <> '';
        MatrixDataVisibility4 := CaptionData[GetControlSetNumber(4)] <> '';
        MatrixDataVisibility5 := CaptionData[GetControlSetNumber(5)] <> '';
        MatrixDataVisibility6 := CaptionData[GetControlSetNumber(6)] <> '';
        MatrixDataVisibility7 := CaptionData[GetControlSetNumber(7)] <> '';
        MatrixDataVisibility8 := CaptionData[GetControlSetNumber(8)] <> '';
        MatrixDataVisibility9 := CaptionData[GetControlSetNumber(9)] <> '';
        MatrixDataVisibility10 := CaptionData[GetControlSetNumber(10)] <> '';
    end;

    local procedure ToggleEditModeAction()
    var
        SensitiveTableWarningLbl: Label 'Warning: You are enabling edit mode on %1. Direct modifications to posted entries may cause data inconsistencies. Do you want to continue?', Comment = '%1 = Table caption';
        TriggersDisabledWarningLbl: Label 'Table triggers are disabled. Business logic will be bypassed during write operations. Do you want to continue?';
    begin
        if not EditModeEnabled then begin
            if TableDataManager.IsSensitiveTable() then
                if not Confirm(SensitiveTableWarningLbl, false, TableDataManager.GetTableCaption()) then
                    exit;

            if not RunTriggers then
                if not Confirm(TriggersDisabledWarningLbl, false) then
                    exit;
        end;

        EditModeEnabled := not EditModeEnabled;
        TableDataManager.SetReadOnlyMode(not EditModeEnabled);
        UpdateEditModeDisplay();
        CurrPage.Update(false);
    end;

    local procedure UpdateEditModeDisplay()
    begin
        if EditModeEnabled then begin
            EditModeDisplayText := EditModeLbl;
            EditModeStyleExpression := 'Attention';
        end else begin
            EditModeDisplayText := ReadOnlyModeLbl;
            EditModeStyleExpression := 'Standard';
        end;
    end;
    // #endregion Local UI Helpers

    var
        TableDataManager: Codeunit "Table Data Manager";
        FieldValueHandler: Codeunit "Field Value Handler";
        RecordWriter: Codeunit "Record Writer";
        DataExportManager: Codeunit "Data Export Manager";
        // #region Visibility Controls
        KeyControlVisibility1: Boolean;
        KeyControlVisibility2: Boolean;
        KeyControlVisibility3: Boolean;
        KeyControlVisibility4: Boolean;
        KeyControlVisibility5: Boolean;
        MatrixDataVisibility1: Boolean;
        MatrixDataVisibility2: Boolean;
        MatrixDataVisibility3: Boolean;
        MatrixDataVisibility4: Boolean;
        MatrixDataVisibility5: Boolean;
        MatrixDataVisibility6: Boolean;
        MatrixDataVisibility7: Boolean;
        MatrixDataVisibility8: Boolean;
        MatrixDataVisibility9: Boolean;
        MatrixDataVisibility10: Boolean;
        // #endregion Visibility Controls
        // #region Configuration
        EditModeEnabled: Boolean;
        RunTriggers: Boolean;
        ValidateFields: Boolean;
        RecordCount: Integer;
        TableNumber: Integer;
        // #endregion Configuration
        // #region Display Arrays
        CaptionData: array[500] of Text;
        KeyCaptionData: array[10] of Text;
        KeyMatrixData: array[10] of Text;
        MatrixData: array[500] of Text;
        // #endregion Display Arrays
        // #region Display Text
        EditModeDisplayText: Text;
        EditModeStyleExpression: Text;
        TargetCompanyName: Text;
        // #endregion Display Text
        // #region Labels
        EditModeLbl: Label 'EDIT MODE';
        ReadOnlyModeLbl: Label 'READ-ONLY';
        // #endregion Labels
}
