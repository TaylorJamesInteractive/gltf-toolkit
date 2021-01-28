/*
[ATTRIBUTE]
[NAME]: babylonMetadata
	This is a default template for GLB metadata. 
	Adapt as you wish for more granular data storage, or use the JSON field to pass more complex data
*/
attributes babylonMetadata 
(
	Parameters main rollout:params
	(	
		x_pos Type:#float UI:spn_Xpos Default:0.0 
		y_pos Type:#float UI:spn_Ypos Default:0.0 
		z_pos Type:#float UI:spn_Zpos Default:0.0		
		mesh_id Type:#integer UI:spn_id Default:0
		mesh_group Type:#string UI:txt_grp Default:""
		url Type:#string UI:txt_url Default:""		
		details Type:#string UI:txt_block Default:""
		json Type:#string UI:json_block Default:""
		isTrigger type:#boolean UI:chk_trigger default:false
		isVisibleOnLoad type:#boolean UI:chk_visible default:true
		-- babylon is y-up and meters - so this should be set to 1 if you are working in metres. We work centimeters 
		unitscale Type:#float Default:0.01
	)
		
	rollout params "Babylon MetaData" width:162 height:55
	(		
		group "Object Position"
		(
		spinner spn_Xpos "X:" width:100 height:16 type:#float range:[-100000000, 1000000000,0]
		spinner spn_Ypos "Y:" width:100 height:16 type:#float range:[-100000000, 1000000000,0]
		spinner spn_Zpos "Z:" width:100 height:16 type:#float range:[-100000000, 1000000000,0]
		
		button btnGetTM "Update Position" height:24 border:false 
		)
	 
		group "Data"
		(
		spinner spn_id "Mesh ID:" Type:#integer across:1 align:#right
		edittext txt_grp "Mesh Group:" across:1 height:16 align:#center
			
		checkbox chk_trigger "Is Trigger" across:1 align:#right
		checkbox chk_visible "Visible On Load" across:1 align:#right
							
		edittext txt_url "URL:" across:1 height:16 align:#center
		edittext txt_block "Text:" across:1 height:30 multiline:true align:#center
		edittext json_block "JSON:" across:1 height:80 multiline:true align:#center
		)
		
		button btnRemove "Remove Attribute" height:24 border:false 
		
		on btnGetTM pressed do ( 
		
			local obj = refs.DependentNodes (refs.dependents this)[1] firstOnly:true
			if obj != undefined then
			(		
				if isValidNode obj then
				(		
				-- babylon is y-up and meters	
				x_pos = obj.position.x * unitscale
				y_pos = obj.position.z * unitscale
				z_pos = obj.position.y * unitscale						
				)
			)			
		) 	

		on btnRemove pressed do
		(
			local defs = custAttributes.getDefs (modPanel.getCurrentObject()) 
			for def in defs where def.name == #babylonMetadata do custAttributes.delete (modPanel.getCurrentObject()) def 						
		)			
	)
)	