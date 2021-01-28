global babylonData
-- Set the working directory to allow the relative structure import
sysInfo.currentdir = getfilenamePath (getsourcefilename())
	
/*
[STRUCT]
[NAME]: babylonDataStruct
	A data structure to add custom metadata to mesh node before export to GLB/Babylon
*/		
Struct babylonDataStruct 
(
	/*
	Import the Attribute Set
	----------------------------------------------------------------
	This file can be changed or duplicated and edited to make custom datasets for export.
	The default attribute should contain data fields that are usable for many potential scenarios. 
	*/
	def = include "_attr/attr_Default.ms",
	
	/*
	[FUNCTION]
	[NAME]: AddBabylonMetadataOnSelection
		Add the metadata attribute to the selection
	[ARGUMENTS]:
		<BOOLEAN> remove: Deletes the attribute if present
		<BOOLEAN> redefine: Redefines the attribute if any changes have been made
	*/
	fn AddBabylonMetadataOnSelection remove:true redefine:true =
	(
		if selection.count > 0 then 
		(
			local objArray = for i in selection collect i
				
			for o in objArray do
			(	
				try (custAttributes.delete o 1)catch()
				custAttributes.add o babylonData.def redefine:redefine
			)	
			objArray
		)
		else (		
			format "Please select an object\n"		
		)
	),

	/*
	[FUNCTION]
	[NAME]: isValidJSON
		Checks if what is set in the text field is a JSON string 
	[ARGUMENTS]:
		<STRING> a JSON formatted string 
	*/
	fn isValidJSON jsonStr =
	(
		true
	),

	/*
	[FUNCTION]
	[NAME]: SetBabylonMetadataOnSelection
		
	[ARGUMENTS]:
		<NODE> obj:
	*/
	mapped fn SetBabylonMetadataOnSelection obj updateTM:true id:unsupplied group:unsupplied url:unsupplied details:unsupplied json:unsupplied isTrigger:false isVisibleOnLoad:true= 
	(
		if isValidNode obj do 
		(
			if updateTM then
			(
			obj.babylonMetadata.x_pos = obj.position.x * obj.babylonMetadata.unitscale
			obj.babylonMetadata.y_pos = obj.position.y * obj.babylonMetadata.unitscale
			obj.babylonMetadata.z_pos = obj.position.z * obj.babylonMetadata.unitscale
			)
			
			if id != unsupplied then try (obj.babylonMetadata.mesh_id = id as integer)catch()
			if group != unsupplied then try (obj.babylonMetadata.mesh_group = group as string)catch()		
			if url != unsupplied then try (obj.babylonMetadata.url = url as string)catch()
			if details != unsupplied then try (obj.babylonMetadata.details = details as string)catch()	
			if json != unsupplied then try (obj.babylonMetadata.json = json as string)catch()	
			if isTrigger != unsupplied then try (obj.babylonMetadata.isTrigger = isTrigger as booleanclass)catch()	
			if isVisibleOnLoad != unsupplied then try (obj.babylonMetadata.isVisibleOnLoad = isVisibleOnLoad as booleanclass)catch()					
		)
	)
)

-- uncomment to redefine struct changes in the scene
-- babylonData = undefined

babylonData = babylonDataStruct()
metaDataObjArray = babylonData.AddBabylonMetadataOnSelection()
-- testing function 
babylonData.SetBabylonMetadataOnSelection metaDataObjArray id:2 group:"Triggers" details:"" url:"" json:"" isTrigger:true isVisible:true
