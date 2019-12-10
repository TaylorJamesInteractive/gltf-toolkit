<img src="http://dev.taylorjames.com/projects/interactive/github/assets/TJI_W.png" align="right"
     title="Taylor James Interactvie" width="70" height="70">
# GLTF Toolkit

> Runs in - 3dsMax 
> Tested in 3dsMax 2016,2018 - should work fine in other versions too.

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/02.png" alt="test image size" height="70%" width="70%">

This is a maxscript to assist the workflow for interactive models. Whilst Substance Painter can export very good GLTF/GLB and USDZ models, it cannot export animated meshes. Therefore we use the [Babylon.js exporter](https://github.com/BabylonJS/Exporters/releases "Babylon.js exporter") to do this from our DDC of choice, 3dsMax.

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/Volvo_AR.jpg" alt="test image size" height="70%" width="70%">

*An example of a GLB file exported from 3dsmax and used in the ARCore modelviewer*

## Preparing GLTF/GLB Assets for Export

Rebinding the PBR texturesets to the rigged and animated model can be time-consuming, and Babylon.js has a precise work flow in order to export the materials correctly from 3dsmax.

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/physical_materials_parameters.png" alt="test image size" height=70% width="70%">
*Image courtesy of the Babylon.js docs*

The main function of the GLTF-Toolbox is to create PBR shaders from Substance Painter output. I would recommend using the USDZ export specification, but it can work with the GLB also. GLB export creates an ORM Map which can be imported by 3dsmax and split into channels, but the exporter doesn't like it. More on using ORM textures [here](https://doc.babylonjs.com/resources/3dsmax_to_gltf#metalness-roughness-and-occlusion-all-in-one-map "here")

## Using the Script

Copy the gltf-tools struct to your scripts directory and run it using the standard maxscript run command (or evaluate the source from the maxscript editor)

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/gltf_tools_full.jpg" alt="test image size" height="50%" width="50%">

#### Set Directory Rollout

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/gltf_tools_pbr.jpg" alt="test image size" height="50%" width="50%">

#### Pick Texture Directory

Browse for a folder that contins the Substance Painter export textures. The script will then attempt to find groups of texture sets from the map names. 

Note - You need to think about how you name the textures on export. This is possible by right-clicking the textureset in Substance Painter before export and renaming it to something meaningful. 

####Prefix Depth 

The script can trim asset names in order to process nested texturesets names, and you choose how many layers you allow the script to look for sets. 

`Globe_Land_<PBR MAP CHANNEL NAME>`
`Globe_Gadgets_<PBR MAP CHANNEL NAME>`
`Globe_Clouds_<PBR MAP CHANNEL NAME>`

If you set prefix depth to 1, you will trim the first underscore from the search, it will find the textureset export for 3 PBR shaders, Land, Gadgets, and Clouds rather than just Globe. 

If you get into the habit of naming your texture set by the mesh group, rather than the asset, this can be added back to the shader name on creation. 

#### Enter Asset Name

 This field can be specified if you want the materials to have an additional prefix on top of the textureset name, or to add back one that you've removed by using prefix depth

#### Create GLTF-PBR Materials

When you've got  viable directory with materials, press this button to build the PBR shaders. If successful, you'll see the Slate editor pop up.

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/03.png" alt="test image size" height=70% width="70%">

Here is a short video of it in action, rebinding a simple material with 2 texturesets. 

![alt text](http://dev.taylorjames.com/projects/interactive/github/assets/babylon_process.gif)

## Scale Tools Rollout
<img src="http://dev.taylorjames.com/projects/interactive/github/assets/gltf_tools_scale.jpg" alt="test image size" height="50%" width="50%">

#### Create AR Size Ref 

Creates a temporary object that is sized at 20 cms x 20 cms x 10 cms. This is an ideal scale for table top AR models as it means the average distance of the viewer will be able to see the model without having to rescale. We have found that the majority of scenarios are in this context and this scale is the most comfortable. 

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/gltf_tools_size_ref_on.png" alt="test image size" height="70%" width="70%">

####Delete AR Size Ref

Clears the scene of any size objects that have been created (You can create as many as you need)

> Working in centimeters is our preferred work flow for our CGI pipeline. Babylon export with 1 unit as 1 meter, so we set the export scale to 0.01

You can see the scale cube we export next to a scale reference sheet below. 
<img src="http://dev.taylorjames.com/projects/interactive/github/assets/scale.png" alt="test image size" height="50%" width="50%">

We have the cube object and the printable scale reference in the repo in the misc_tools folder.

## Rigging Tools

<img src="http://dev.taylorjames.com/projects/interactive/github/assets/gltf_tools_rigging.jpg" alt="test image size" height="50%" width="50%">


#### Create Root Helper
Makes a neutral transform helper at the world origin.

#### Setup Skin For Export
Sets a few parameters to make it easier to work with skin, along with limiting the bone weights per vertex to 4.

## Material Tools
<img src="http://dev.taylorjames.com/projects/interactive/github/assets/gltf_tools_materials.jpg" alt="test image size" height="50%" width="50%">

#### Create New Physical Material

Creates a physical shader with basic parameters, useful if you want to make flat shaded PBR models without additional texture maps, just using the standard diffuse colour as the albedo.

#### Clear Slate Editor

Does exactly that.

#### Open Export Dialog

Might have to clear up with Babylon.js about how to call this, as they have wrapped it up in an Actionman call rather than a maxscript dialog. It's a DotNet dialog that they invoke, but I can't figure out the constructor for this.


