using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Autodesk.AutoCAD.Runtime;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.ProcessPower.PnIDObjects;
using Autodesk.ProcessPower.PlantInstance;
using Autodesk.ProcessPower.ProjectManager;
using Autodesk.ProcessPower.PnIDGUIUtil;
using Autodesk.ProcessPower.Styles;

[assembly: CommandClass(typeof(ClassLibrary1.Class1))]

namespace ClassLibrary1
{
    public class Class1
    {
        
        public void AdskGreeting1()
        {
            // Get the current document and database, and start a transaction
            Document acDoc = Application.DocumentManager.MdiActiveDocument;
            Database acCurDb = acDoc.Database;

            // Starts a new transaction with the Transaction Manager
            using (Transaction acTrans = acCurDb.TransactionManager.StartTransaction())
            {
                // Open the Block table record for read
                BlockTable acBlkTbl;
                acBlkTbl = acTrans.GetObject(acCurDb.BlockTableId,
                                             OpenMode.ForRead) as BlockTable;

                // Open the Block table record Model space for write
                BlockTableRecord acBlkTblRec;
                acBlkTblRec = acTrans.GetObject(acBlkTbl[BlockTableRecord.ModelSpace],
                                                OpenMode.ForWrite) as BlockTableRecord;

                /* Creates a new MText object and assigns it a location,
                text value and text style */
                using (MText objText = new MText())
                {
                    // Specify the insertion point of the MText object
                    objText.Location = new Autodesk.AutoCAD.Geometry.Point3d(2, 2, 0);

                    // Set the text string for the MText object
                    objText.Contents = "Greetings, Welcome to AutoCAD .NETZZZ";

                    // Set the text style for the MText object
                    objText.TextStyleId = acCurDb.Textstyle;

                    // Appends the new MText object to model space
                    acBlkTblRec.AppendEntity(objText);

                    // Appends to new MText object to the active transaction
                    acTrans.AddNewlyCreatedDBObject(objText, true);
                }

                // Saves the changes to the database and closes the transaction
                acTrans.Commit();
            }
        }

        [CommandMethod("AdskGreeting")]
        public void AdskGreeting()
        {
            Database db = Application.DocumentManager.MdiActiveDocument.Database;
            Autodesk.AutoCAD.EditorInput.Editor ed = Application.DocumentManager.MdiActiveDocument.Editor;
            ed.WriteMessage("foo foo foo");

            Autodesk.AutoCAD.DatabaseServices.TransactionManager tm = db.TransactionManager;
            using (Transaction tr = tm.StartTransaction())
            {
                BlockTable bt = (BlockTable)tm.GetObject(db.BlockTableId, OpenMode.ForRead);
                BlockTableRecord btr = (BlockTableRecord)tm.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForRead);

                //P&ID Entities are Assets or LineSegments
                foreach (ObjectId oid in btr)
                {
                    Entity entity = (Entity)tm.GetObject(oid, OpenMode.ForRead);
                    Autodesk.ProcessPower.PnIDObjects.Asset asset = entity as Asset;
                    Autodesk.ProcessPower.PnIDObjects.LineSegment linesegment = entity as LineSegment;

                    string sMsg = "";
                    if (asset != null)
                        sMsg = "\nAsset: " + asset.ClassName;
                    if (linesegment != null)
                        sMsg = "\nLineSegment: " + linesegment.ClassName;

                    ed.WriteMessage(sMsg);
                }
            }
        }
    }
}