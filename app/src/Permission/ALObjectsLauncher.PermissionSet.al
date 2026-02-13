namespace SamueleCelebron.ObjectLauncher;

permissionset 50100 "AL Objects Launcher"
{
    Assignable = true;
    Caption = 'AL Objects Launcher';

    Permissions =
        page "AL Objects Launcher" = X,
        page "Sorting Keys" = X,
        page "Table Data Editor" = X,
        codeunit "Table Data Manager" = X,
        codeunit "Field Value Handler" = X,
        codeunit "Record Writer" = X,
        codeunit "Data Export Manager" = X;
}
