
global gltfTools 

/*
[STRUCT]: PBRMap
	A data object to store the configuration of a PBR Shader
*/
struct PBRMap 
(
	name,
	maps, 
	base_color,
	roughness, 
	metalness, 
	specular, 
	occlusion,
	bump, 
	transparency, 
	emission,
	base_color_map,
	roughness_map, 
	metalness_map, 
	specular_map, 
	occlusion_map, 
	bump_map, 
	transparency_map, 
	emission_map
)

/*
[STRUCT]: ORM
	A data object to allow the splitting of an ORM map into three 8 bit grayscale channels
*/
struct ORM
(
	source,
	metallic,
	roughness,
	occlusion
)

/*
[STRUCT]: gltfToolsStruct
	Some tools to assist re-build shaders from substance painter maps to allow GLB/GLTF export for realtime applications

	Babylon exporter is used in 3dsMax to export data to GLB/GLTF - 

	Useful resources - GLB/GLTF requires a Physically Based Shader workflow - https://doc.babylonjs.com/resources/3dsmax_to_gltf#pbr-materials
		
	This toolset is an automation of the shader process documented here - https://doc.babylonjs.com/resources/3dsmax_to_gltf#pbr-materials
	
*/
struct gltfToolsStruct 
(
	
textures_dir = (getdir #scene ) ,
-- TO_DO - Can't find a way to expose the running of the babylon exporter dialog from DotNet
-- babylonExportCall
-- babylonProperties = [91,1]
-- 
	
	/*
	[FUNCTION]: setupSkinParameters
		Sets the skin modifier up for export - most notasbly the boner affect limit 	
	*/
	fn setupSkinParameters =
	(	
			cSel = if selection.count > 0 then 
				for obj in selection collect obj
					else objects
			
			max modify mode		
			
			for i in cSel where isProperty i #skin do
			(
				sk = i.modifiers[#Skin]
				modPanel.setCurrentObject sk
				subobjectLevel = 1
				sk.filter_vertices = on
				sk.bone_Limit = 4
					
				if (skinOps.GetNumberVertices sk) > 0 then
				(
				skinOps.SelectVertices sk #{1..(skinOps.GetNumberVertices sk)}
				skinOps.bakeSelectedVerts sk
				sk.showNoEnvelopes = true	
				skinOps.SelectVertices sk #{}
				subobjectLevel = 0
				)
			)
	),
		
	/*
	[FUNCTION]: createARSizeRef
		Creates a 20cm box, suitable to check sizing on tabletop AR projects 
	[RETURN]: none
	*/
	fn createARSizeRef = box length:20 width:20 height:10 wirecolor:green transform:(matrix3 1) isfrozen:false name:(uniquename"_AR_Table_Size_Ref_") boxmode:off,
		
	/*
	[FUNCTION]: removeARSizeRefs
		Deletes the AR size boxes
	[RETURN]: none
	*/
	fn removeARSizeRefs =
	(
		local arRefs = for o in objects where matchpattern o.name pattern:"_AR_Table_Size_Ref_*" collect o
		if arRefs != undefined and arRefs.count > 0 then delete arRefs
	),

	/*
	[FUNCTION]: createRootPoint
		Creates a world zero helper object root
	[RETURN]: the newly created point
	*/
	fn createRootPoint = point box:on cross:off size:40 wirecolor:yellow transform:(matrix3 1) constantscreensize:off centermarker:off axistripod:off drawontop:off,

	/*
	[FUNCTION]: slateViewSpringClean
		Clears the SME of all views
	[RETURN]: none
	*/
	fn slateViewSpringClean = 
	(
			if not sme.isopen() then sme.open() 
			local vcount = sme.GetNumViews() 
			if vcount > 0 then
				for i = vcount to 1 by -1 do sme.DeleteView i false			
	),


	/*
	[FUNCTION]: CreateSlateTab
		Creates a new slate tab to view an array of materials.
	[ARGUMENTS]:
		<STRING> tabName : The title to use on the tab
		<ARRAY> mats : An array of material shaders
	[OPTIONAL ARGUMENTS]:
		<BOOLEAN> clear : removes any existing Slate tabs
		<POINT2> offset : a value to set the layout distance between materials
	[RETURN]: none
	*/
	fn CreateSlateTab tabName mats clear:false offset:[500,0] =
	(	
		if sme != undefined then 
		(	
			if not sme.isopen() then sme.open() 
			

			
			local vcount = sme.GetNumViews() 		
			
			if clear then 
				for i = vcount to 1 by -1 do sme.DeleteView i false

			local viewInt = sme.GetViewByName tabName 
			if viewInt == 0 then					
				viewInt = sme.CreateView tabName
			
			local iView = sme.GetView viewInt
			local mat_array = #()
			for mat =1 to mats.count do
			(
				if iView != undefined then
				(
					iView.CreateNode mats[mat] [mat*offset.x, mat*offset.y]	
					appendifunique mat_array mats[mat]			
					bmps = getclassinstances bitmaptexture target:mats[mat]
					join mat_array bmps
				)
			)		
			iView.SetSelectedNodes mat_array
			iView.ZoomExtents type:#selected
			iView.SetSelectedNodes #()
		)	
	),

	/*
	[FUNCTION]: getMapAssetNames
		Trims the first string section of a filename using an underscore delimiter
	[OPTIONAL ARGUMENTS]:
		<BOOLEAN> bypass_prefix :jumps to the second underscore for any edge case scenarios
	[RETURN]:
		<ARRAY> returns a sorted string array
	*/
	fn getMapAssetNames mapArray bypass_prefix:false search_depth:1 =
	(
		objNames = sort(makeuniquearray \
							(
								for i in mapArray collect 
								(
									local f = getfilenamefile i
									objParts = filterstring f "_"
									
									--format "filename: % objparts: % count:%\n" f objParts objparts.count
									
									--int_Name = undefined 
									
									int_Name = if search_depth <= objParts.count then search_depth else objParts.count
																	
									if objParts.count > 1 then
									(
										--stringstream
										local prefix_name = ""
																			
										for i = 1 to int_Name do 
										(
											if (i == int_Name) then prefix_name+= objParts[i]
												else prefix_name+= (objParts[i] + "_")
											--	else if i == 1 then prefix_name+= (objParts[i] + "_")
														
										)
										

										
										--format "prefix_name: % " prefix_name
										prefix_name
											
	-- 										objParts[i] + "_" + objParts[2] + "_" + objParts[3] + "_" + objParts[4] 
	-- 											else objParts[1] 
										
									)								
									else dontCollect  	

	-- 								if objParts.count > 1 then
	-- 								(
	-- 									if bypass_prefix then 
	-- 										objParts[1] + "_" + objParts[2] + "_" + objParts[3] + "_" + objParts[4] 
	-- 											else objParts[1] 
	-- 								)								
	-- 								else dontCollect  


									
								)
							)
						)
	),

	/*
	[FUNCTION]: splitORMTexture
		Takes an ORM texturemap and splits it into 3 8-bit grayscale channels in order to plug into a physical shader
	[ARGUMENTS]:
		<STRING> assetName : The map prefix
		<STRING> src : The source path to the ORM texture
	[RETURN]: an ORM struct instance containing the 3 split channels
	*/
	fn splitORMTexture assetName src = 
	(
		local ormInst	

		if doesfileexist src then
		(
			ormInst = ORM()
			ormInst.source = Bitmaptexture fileName:src name:(assetName +"ORM Map")
			local strChannel = #("R","G","B")
			channels = for i = 1 to 3 collect colorcorrection map:ormInst.source rewireMode:3 rewireR:(i-1) rewireG:(i-1) rewireB:(i-1) name:(assetName + "_" + strChannel[i] + "_Channel")
			--ORM Channel Order - Occlusion = r Roughness = g Metal = b
			ormInst.occlusion = channels[1]
			ormInst.roughness = channels[2]
			ormInst.metallic = channels[3]

		)	
		format "ormInst - an - %\t\nsrc - %\t\nOrmIst - %\n" assetname (getfilenamefile src) ormInst
		ormInst
	),


	fn filterSubstanceMaps dir types:#("jpg","png") delimiter:"_" search_depth:1 =
	(	
		if doesfileexist dir then
		(		
			local substanceMaps = #()
			
			for type in types do
			(
				local searchPath = pathconfig.appendpath dir (@"/*." + type)
				mapFiles = getfiles searchPath
				if mapFiles != undefined then join substanceMaps mapFiles 
			)

			
			local matNames = gltfTools.getMapAssetNames substanceMaps search_depth:search_depth --bypass_prefix:bypass_prefix

			local pbrStructArray = for each in matNames collect 
			(	
				asset_maps = for s in substanceMaps where matchpattern (getfilenamefile s) pattern:(each + "_*") ignorecase:true collect s	
				
				local pbr = PBRMap name:each	
				
				for s in asset_maps do
				(

						local filename = getfilenamefile s
						
						local isORMtex = false
						local ormInst = undefined
						
						if matchpattern filename pattern:("*occlusion*Roughness*Metallic*") then
						(
							isORMtex = true
							format "isORMtex - % %\n" isORMtex s
							ormInst = gltfTools.splitORMTexture each s
						)

						
						if isORMtex then
						(
							-- we just need to populate the ORM channels direectly, the others will be passed via the standard case statement regardless
							pbr.occlusion_map = ormInst.occlusion
							pbr.metalness_map = ormInst.metallic
							pbr.roughness_map = ormInst.roughness
						)
						else -- it's a standard PBR substance export
						(
							case of 
							(
								((matchpattern filename pattern:(each +"*occlusion*")) or (matchpattern filename pattern:(each +"*ao*"))):pbr.occlusion_map = (if isORMtex then ormInst.occlusion else s)
								((matchpattern filename pattern:(each +"*base*")) or (matchpattern filename pattern:(each +"*albedo*"))):pbr.base_color_map = s
								(matchpattern filename pattern:(each +"*metal*")):pbr.metalness_map = (if isORMtex then ormInst.metallic else s)
								(matchpattern filename pattern:(each +"*rough*")):pbr.roughness_map = (if isORMtex then ormInst.roughness else s)	
								((matchpattern filename pattern:(each +"*normal*")) or (matchpattern filename pattern:(each +"*ao*"))):pbr.bump_map = s
								(matchpattern filename pattern:(each +"*emiss*")):pbr.emission_map = s
								default:()
							)
						)	
				)
				pbr.maps = asset_maps			
				pbr
			)	
			
			pbrStructArray
		)-- end if doesfileexist
		else format "The path does not exist - % \n" dir
	),

	fn buildPBRBaseShader matName base_color:undefined base_color_map:undefined \
													roughness:1.0 roughness_map:undefined \
														metalness:1.0 metalness_map:undefined metalGlossy:false\
															occlusion_map:undefined \
																bump_map_amt:0.3 bump_map:undefined \
																	transparency:0.0 transparency_map:undefined \
																		emission:0.0 emit_color:white emission_map:undefined =
	(
		pbr_mat = PhysicalMaterial()	
		pbr_mat.name = matName 
				
		--parameters section 
		if base_color != undefined then pbr_mat.base_color = (base_color as point4) else pbr_mat.base_color = (white as point4)
		if roughness != undefined then pbr_mat.roughness = roughness  
		if metalGlossy != undefined then pbr_mat.roughness_inv  = metalGlossy
		if metalness != undefined then pbr_mat.metalness = metalness
		if transparency != undefined then pbr_mat.transparency = transparency
		if bump_map_amt != undefined then pbr_mat.bump_map_amt = bump_map_amt
		if emission != undefined then pbr_mat.emission = emission
		if emit_color != undefined then pbr_mat.emit_color = emit_color as point4

		--texturemap section 
		
		if base_color_map != undefined and doesfileexist base_color_map then
		(		
			pbr_mat.base_color_map = bitmaptexture fileName:base_color_map name:(matName + "_albedo")			
			showTextureMap pbr_mat pbr_mat.base_color_map on
		)

		if roughness_map != undefined then
		(
			if superclassof roughness_map == texturemap then
			(
				roughness_map.name = matName +"_roughness"
				pbr_mat.roughness_map = roughness_map
			)
			else
			(
				if doesfileexist roughness_map then 	
					pbr_mat.roughness_map = bitmaptexture fileName:roughness_map name:(matName +"_roughness")
			)
		)
		
		if metalness_map != undefined then
		(
			if superclassof metalness_map == texturemap then
			(
				metalness_map.name = matName +"_metallic"
				pbr_mat.metalness_map = metalness_map
			)
			else
			(
				if doesfileexist metalness_map then 	
					pbr_mat.metalness_map = bitmaptexture fileName:metalness_map name:(matName +"+metallic")
			)
		)
		
		if occlusion_map != undefined then
		(
			if superclassof occlusion_map == texturemap then
			(
				occlusion_map.name = matName +"_occlusion"
				pbr_mat.diff_rough_map = occlusion_map
			)
			else
			(
				if doesfileexist occlusion_map then 	
					pbr_mat.diff_rough_map = bitmaptexture fileName:occlusion_map name:(matName +"_occlusion")
			)
		)

		if bump_map != undefined and doesfileexist bump_map then 	
			pbr_mat.bump_map = bitmaptexture fileName:bump_map name:(matName +"_normalBump")
		
		if transparency_map != undefined and doesfileexist transparency_map then 
			pbr_mat.transparency_map = bitmaptexture fileName:transparency_map name:(matName +"_transparency")
		
		if emission_map != undefined and doesfileexist emission_map then 
			pbr_mat.emission_map = bitmaptexture fileName:emission_map name:(matName +"_emmisive")

		pbr_mat		
		
	),


	fn process assetName dir search_depth:1 =
	(
			local exportData = gltfTools.filterSubstanceMaps dir search_depth:search_Depth -- bypass_prefix:bypass_prefix
			--clearlistener()
			for f in exportData do format "Shader Params - %\n" f
		
			pbr_mats = for d in exportData collect
			(
			--	format "occlusion %\n" d.occlusion_map
			--	format "roughness %\n" d.roughness_map
			--	format "metallic %\n" d.metalness_map
				
				 gltfTools.buildPBRBaseShader (assetName + "_" + d.name) base_color:undefined base_color_map:d.base_color_map \
																roughness:0.0 roughness_map:d.roughness_map \
																	metalness:0.0 metalness_map:d.metalness_map metalGlossy:false \
																		occlusion_map:d.occlusion_map \
																			bump_map_amt:0.3 bump_map:d.bump_map \
																				transparency:0.0 transparency_map:d.transparency_map \
																					emission:0.0 emit_color:white emission_map:d.emission_map

			)
			
			format "pbr_mats %\n" pbr_mats
			if pbr_mats != undefined then
				 gltfTools.CreateSlateTab assetName pbr_mats clear:false
	),

	
gltfToolsRo = rollout gltfToolsRo "Taylor James Interactive - GLTF Toolkit" width:400
(
	local bm = openbitmap (pathconfig.appendPath (getfilenamepath (getsourcefilename())) "logo.png") 

	imgtag logo width:400 height:120  bitmap:bm pos:[0,0]

	group "Set Directory"
	(
	button 'pickDir' "Pick Texture Directory..."  width:380  align:#center 			
	spinner 'spn_searchDepth' "Prefix Depth:" range:[1,10,1] type:#integer		
	label 'mapFiles' "Textures Found - " enabled:false align:#center		
	edittext 'assetName' "Enter Asset Name" width:380 align:#center enabled:false
	button 'btnMake' "Create GLTF-PBR Materials"  width:380  align:#center across:1 enabled:false
	)
		
	group "Scale Tools"
	(
	button 'btnARRef' "Create AR Size Ref"  width:180  align:#center across:2
	button 'btnARrefClear' "Delete AR Size Ref"  width:180 align:#center across:2
	)
	
	group "Rigging Tools"
	(
	button 'btnCreateRoot' "Create Root Helper"  width:180  align:#center across:2
	button 'btnSkinSetup' "Setup Skin For Export"  width:180 align:#center across:2
	)
		
	group "Material Tools"
	(
	button 'btnCreate' "Create New Physical Material"  width:180  align:#center across:2
	button 'btnClearSlate' "Clear Slate Editor"  width:180  align:#center across:2
	)

	
	button 'openExporter' "Open Export Dialog"  width:380 align:#center across:1
	
	on btnARRef pressed do gltfTools.createARSizeRef()
	on btnARrefClear pressed do gltfTools.removeARSizeRefs()
	on btnCreateRoot pressed do gltfTools.createRootPoint()
	on btnSkinSetup pressed do gltfTools.setupSkinParameters()
	on btnClearSlate pressed do gltfTools.slateViewSpringClean()
  
	
	on btnMake pressed do
	(
		with animate off
		(
		if  gltfTools.textures_dir != undefined and doesfileexist  gltfTools.textures_dir then
				gltfTools.process assetName.text gltfTools.textures_dir search_Depth:spn_searchDepth.value

		)	
	)
	
	on btnCreate pressed do
	(
		with animate off
		(
		new_pbr_mat = gltfTools.buildPBRBaseShader (uniquename "gltf_base_") base_color:white roughness:0.5 metalness:0.5
		gltfTools.CreateSlateTab "Gltf" #(new_pbr_mat) clear:false
		)
		
	)
	
	on chkTrimPrefix changed state do
	(
		pickDir.pressed()
	)

	on pickDir pressed do
	(
	
 		local init_dir = if doesfileexist gltfTools.textures_dir then gltfTools.textures_dir else getdir #scene
		scan_path = getSavePath  caption:"Pick Substance output directory" initialDir:init_dir
		
		if scan_path != undefined then
		(
			gltfTools.textures_dir = scan_path
			mapFiles.enabled = assetName.enabled = true
			mapFiles.text = "Processing Directory..."
			pickDir.text = scan_path
			exportData = gltfTools.filterSubstanceMaps scan_path search_depth:spn_searchDepth.value --bypass_prefix:chkTrimPrefix.state
			
			if exportData != undefined and exportData.count > 0 then
			(
				end_str = if exportData.count == 1 then  "Material Found" else "Materials Found"
				mapFiles.text = (exportData.count as string) +  " Substance Export " + end_str
				btnMake.enabled = true
			)
			else 
			(
				mapFiles.text = "No Materials Found"
				btnMake.enabled = false
			)
		)
	)
	
	
	
	on openExporter pressed do actionMan.executeAction 91 "1" 
	

),

fn ui = (

	createdialog gltfToolsRo
)


)

-- Testing
-- gltfToolsRo = undefined
-- gltfTools = undefined

gltfTools = gltfToolsStruct ()
try (destroydialog gltfTools.gltfToolsRo) catch()
gltfTools.ui()

