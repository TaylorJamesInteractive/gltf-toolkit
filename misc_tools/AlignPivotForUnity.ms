
/*
	[FUNCTION]: AlignPivotForUnity
		Sets the pivot alignment for correct TM value export to Unity.
	[ARGUMENTS]:
		<NODE> obj : The object to be exported
	[OPTIONAL ARGUMENTS]:
		<BOOLEAN> addMat : Adds a default grey standard material
	[RETURN]: none
	[USAGE]: function - Call AlignPivotForUnity selection[1] or for i in selection do AlignPivotForUnity i
*/	
fn AlignPivotForUnity obj addMat:true =
(	
	obj.showFrozenInGray = off

	local rotValInv=inverse ((eulerAngles 90 0 0) as quat)
	animate off in coordsys local obj.rotation*=RotValInv
	obj.objectoffsetpos*=RotValInv
	obj.objectoffsetrot*=RotValInv
	
	if addMat then
	(
		m = standard diffuse:gray name:(obj.name + "_Mat")
		obj.material = m
	)
)

