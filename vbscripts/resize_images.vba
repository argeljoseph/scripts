Sub ResizeImagesAndCenter()
    Dim i As Long
    With ActiveDocument
        For i = 1 To .InlineShapes.Count
            If .InlineShapes(i).Type = wdInlineShapePicture Then ' Check if the InlineShape is an image
                With .InlineShapes(i)
                    .LockAspectRatio = msoTrue ' Locks the aspect ratio
                    .Width = CentimetersToPoints(12.5) ' Sets the width to 12.5 centimeters
                End With
            End If
        Next i
    End With

    ' Center the images within their table cells
    Dim tbl As Table
    For Each tbl In ActiveDocument.Tables
        Dim cell As cell
        For Each cell In tbl.Range.Cells
            If cell.Range.InlineShapes.Count > 0 Then
                cell.Range.ParagraphFormat.Alignment = wdAlignParagraphCenter
            End If
        Next cell
    Next tbl
End Sub
