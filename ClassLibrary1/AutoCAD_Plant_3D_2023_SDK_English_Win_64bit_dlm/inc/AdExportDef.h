/////////////////////////////////////////////////////////////////////////////
//
// $Header: //depot/PlatformSDK/current/RibbonAppFrame/develop/sdk/include/internal/AdApplicationFrame/AdExportDef.h#1 $
// $Author: yinl $ $DateTime: 2013/07/10 00:53:25 $ $Change: 428639 $
// $NoKeywords: $
//////////////////////////////////////////////////////////////////////////////
//
// (C) Copyright 2009-2011 by Autodesk, Inc.
//
// Permission to use, copy, modify, and distribute this software in
// object code form for any purpose and without fee is hereby granted, 
// provided that the above copyright notice appears in all copies and 
// that both that copyright notice and the limited warranty and
// restricted rights notice below appear in all supporting 
// documentation.
//
// AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS. 
// AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC. 
// DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
// UNINTERRUPTED OR ERROR FREE.
//
// Use, duplication, or disclosure by the U.S. Government is subject to 
// restrictions set forth in FAR 52.227-19 (Commercial Computer
// Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii)
// (Rights in Technical Data and Computer Software), as applicable.
//
//////////////////////////////////////////////////////////////////////////////
//
// Name:            AdExportDef.h
//
//////////////////////////////////////////////////////////////////////////////

#pragma once

#ifdef  _ADAF_BUILD
#  define   ADAF_PORT  __declspec(dllexport)
#else
#  define   ADAF_PORT  __declspec(dllimport)
#endif