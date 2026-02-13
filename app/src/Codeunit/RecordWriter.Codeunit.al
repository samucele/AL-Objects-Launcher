namespace SamueleCelebron.ObjectLauncher;

using System.Reflection;

/// <summary>
/// Stateless codeunit responsible for all database mutation operations (insert, modify,
/// delete, rename) and publishing integration events for each write.
/// Receives ReadOnlyMode as a Boolean parameter for independence from the Table Data Manager.
/// Every write operation is guarded by a read-only check and fires an integration event
/// before the actual database call.
/// </summary>
codeunit 50102 "Record Writer"
{
    #region Write Operations

    /// <summary>
    /// Modifies an existing record in the database.
    /// Guards against read-only mode and fires OnBeforeGenericDatabaseWrite before the operation.
    /// </summary>
    /// <param name="RecordReference">The positioned RecordRef to modify.</param>
    /// <param name="RunTriggers">Whether to run table triggers during modification.</param>
    /// <param name="ReadOnlyMode">When true, the operation is blocked with an error.</param>
    procedure ModifyRecord(var RecordReference: RecordRef; RunTriggers: Boolean; ReadOnlyMode: Boolean)
    var
        IsHandled: Boolean;
    begin
        GuardReadOnlyMode(ReadOnlyMode);

        OnBeforeGenericDatabaseWrite(RecordReference, RunTriggers, Enum::"Database Operation Type"::Modify, IsHandled);
        if not IsHandled then
            RecordReference.Modify(RunTriggers);
    end;

    /// <summary>
    /// Inserts a new record into the database.
    /// Guards against read-only mode and fires OnBeforeGenericDatabaseWrite before the operation.
    /// </summary>
    /// <param name="RecordReference">The RecordRef with field values set for insertion.</param>
    /// <param name="RunTriggers">Whether to run table triggers during insertion.</param>
    /// <param name="ReadOnlyMode">When true, the operation is blocked with an error.</param>
    procedure InsertRecord(var RecordReference: RecordRef; RunTriggers: Boolean; ReadOnlyMode: Boolean)
    var
        IsHandled: Boolean;
    begin
        GuardReadOnlyMode(ReadOnlyMode);

        OnBeforeGenericDatabaseWrite(RecordReference, RunTriggers, Enum::"Database Operation Type"::Insert, IsHandled);
        if not IsHandled then
            RecordReference.Insert(RunTriggers);
    end;

    /// <summary>
    /// Deletes an existing record from the database.
    /// Guards against read-only mode and fires OnBeforeGenericDatabaseWrite before the operation.
    /// </summary>
    /// <param name="RecordReference">The positioned RecordRef to delete.</param>
    /// <param name="RunTriggers">Whether to run table triggers during deletion.</param>
    /// <param name="ReadOnlyMode">When true, the operation is blocked with an error.</param>
    procedure DeleteRecord(var RecordReference: RecordRef; RunTriggers: Boolean; ReadOnlyMode: Boolean)
    var
        IsHandled: Boolean;
    begin
        GuardReadOnlyMode(ReadOnlyMode);

        OnBeforeGenericDatabaseWrite(RecordReference, RunTriggers, Enum::"Database Operation Type"::Delete, IsHandled);
        if not IsHandled then
            RecordReference.Delete(RunTriggers);
    end;

    /// <summary>
    /// Deletes all records matching the current filters on the RecordRef.
    /// Shows a confirmation dialog before proceeding. Returns true if records were deleted.
    /// </summary>
    /// <param name="RecordReference">The filtered RecordRef whose records will be deleted.</param>
    /// <param name="RunTriggers">Whether to run table triggers during deletion.</param>
    /// <param name="ReadOnlyMode">When true, the operation is blocked with an error.</param>
    /// <returns>True if the user confirmed and records were deleted, false if cancelled.</returns>
    procedure DeleteAllRecords(var RecordReference: RecordRef; RunTriggers: Boolean; ReadOnlyMode: Boolean): Boolean
    begin
        GuardReadOnlyMode(ReadOnlyMode);

        if not Confirm(ConfirmDeleteAllLbl, false, RecordReference.Count) then
            exit(false);

        RecordReference.DeleteAll(RunTriggers);
        exit(true);
    end;

    /// <summary>
    /// Renames a record by changing one of its primary key field values.
    /// Reads all current PK values, restores the old value on the changed field to position
    /// the RecordRef on the original record, then renames with the new PK values.
    /// Fires OnBeforeGenericDatabaseRename before the operation.
    /// Updates the record dictionary via the Table Data Manager after successful rename.
    /// </summary>
    /// <param name="RecordReference">The RecordRef positioned on the record to rename.</param>
    /// <param name="PrimaryKeyFieldReference">The FieldRef of the PK field being changed.</param>
    /// <param name="OldValue">The original value of the PK field before the change.</param>
    /// <param name="TableNumber">The table number, used to look up primary key fields.</param>
    /// <param name="ReadOnlyMode">When true, the operation is blocked with an error.</param>
    /// <param name="TableDataManager">The Table Data Manager for dictionary update and field lookup.</param>
    /// <param name="RowNumber">The row number in the dictionary to update after rename.</param>
    procedure RenameRecord(var RecordReference: RecordRef; var PrimaryKeyFieldReference: FieldRef; OldValue: Variant; TableNumber: Integer; ReadOnlyMode: Boolean; var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer)
    var
        FieldRecord: Record "Field";
        FieldReference: FieldRef;
        IsHandled: Boolean;
        Index: Integer;
        PrimaryKeyFieldCount: Integer;
        PrimaryKeyValue1: Variant;
        PrimaryKeyValue2: Variant;
        PrimaryKeyValue3: Variant;
        PrimaryKeyValue4: Variant;
        PrimaryKeyValue5: Variant;
    begin
        GuardReadOnlyMode(ReadOnlyMode);

        // Read current PK field values (including the new value on the changed field)
        TableDataManager.GetFilteredFieldRecord(FieldRecord);
        FieldRecord.SetRange(IsPartOfPrimaryKey, true);
        if FieldRecord.FindSet() then
            repeat
                FieldReference := RecordReference.Field(FieldRecord."No.");
                Index += 1;
                case Index of
                    1:
                        PrimaryKeyValue1 := FieldReference.Value;
                    2:
                        PrimaryKeyValue2 := FieldReference.Value;
                    3:
                        PrimaryKeyValue3 := FieldReference.Value;
                    4:
                        PrimaryKeyValue4 := FieldReference.Value;
                    5:
                        PrimaryKeyValue5 := FieldReference.Value;
                end;
            until FieldRecord.Next() = 0;

        PrimaryKeyFieldCount := FieldRecord.Count;

        // Restore the old value so RecRef points to the original record for the rename
        PrimaryKeyFieldReference.Value(OldValue);

        OnBeforeGenericDatabaseRename(RecordReference, PrimaryKeyFieldCount,
            PrimaryKeyValue1, PrimaryKeyValue2, PrimaryKeyValue3, PrimaryKeyValue4, PrimaryKeyValue5,
            IsHandled);

        if not IsHandled then
            case PrimaryKeyFieldCount of
                1:
                    RecordReference.Rename(PrimaryKeyValue1);
                2:
                    RecordReference.Rename(PrimaryKeyValue1, PrimaryKeyValue2);
                3:
                    RecordReference.Rename(PrimaryKeyValue1, PrimaryKeyValue2, PrimaryKeyValue3);
                4:
                    RecordReference.Rename(PrimaryKeyValue1, PrimaryKeyValue2, PrimaryKeyValue3, PrimaryKeyValue4);
                5:
                    RecordReference.Rename(PrimaryKeyValue1, PrimaryKeyValue2, PrimaryKeyValue3, PrimaryKeyValue4, PrimaryKeyValue5);
                else
                    Error(UnsupportedPrimaryKeyCountErr, PrimaryKeyFieldCount);
            end;

        TableDataManager.UpdateRecordId(RowNumber, RecordReference.RecordId);
    end;

    #endregion

    #region Integration Events

    /// <summary>
    /// Raised before any generic database write operation (insert, modify, delete).
    /// Subscribers can set IsHandled to true to prevent the default write behavior.
    /// </summary>
    /// <param name="RecordReference">The RecordRef being written.</param>
    /// <param name="RunTriggers">Whether table triggers will be executed.</param>
    /// <param name="OperationType">The type of database operation being performed.</param>
    /// <param name="IsHandled">Set to true to prevent the default write operation.</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGenericDatabaseWrite(var RecordReference: RecordRef; RunTriggers: Boolean; OperationType: Enum "Database Operation Type"; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before a record rename operation.
    /// Subscribers can set IsHandled to true to prevent the default rename behavior.
    /// </summary>
    /// <param name="RecordReference">The RecordRef being renamed.</param>
    /// <param name="PrimaryKeyFieldCount">The number of primary key fields.</param>
    /// <param name="Value1">The first primary key value.</param>
    /// <param name="Value2">The second primary key value (if applicable).</param>
    /// <param name="Value3">The third primary key value (if applicable).</param>
    /// <param name="Value4">The fourth primary key value (if applicable).</param>
    /// <param name="Value5">The fifth primary key value (if applicable).</param>
    /// <param name="IsHandled">Set to true to prevent the default rename operation.</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGenericDatabaseRename(var RecordReference: RecordRef; PrimaryKeyFieldCount: Integer; Value1: Variant; Value2: Variant; Value3: Variant; Value4: Variant; Value5: Variant; var IsHandled: Boolean)
    begin
    end;

    #endregion

    #region Guards

    /// <summary>
    /// Raises an error if the system is in read-only mode, preventing any write operation.
    /// </summary>
    /// <param name="ReadOnlyMode">The current read-only mode setting.</param>
    procedure GuardReadOnlyMode(ReadOnlyMode: Boolean)
    begin
        if ReadOnlyMode then
            Error(CannotWriteInReadOnlyModeErr);
    end;

    #endregion

    var
        CannotWriteInReadOnlyModeErr: Label 'Cannot perform write operations in read-only mode. Enable edit mode to modify data.';
        ConfirmDeleteAllLbl: Label 'Do you want to delete all %1 filtered records?', Comment = '%1 = Number of records';
        UnsupportedPrimaryKeyCountErr: Label 'Unsupported primary key field count: %1. Maximum supported is 5.', Comment = '%1 = Field count';
}
