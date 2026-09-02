extends Resource
class_name SeedData

## Defines a plantable seed with all its properties
## This resource can be created in the inspector and reused for different seed types

@export var seed_name: String = "Unknown Seed"
@export_multiline var description: String = ""
@export var icon: Texture2D

## The plant scene that will be spawned when this seed is planted
@export var plant_scene: PackedScene

## Total time in seconds for the plant to reach full maturity
@export var total_growth_time: float = 30.0

## Number of growth stages (including the initial planted stage)
@export var growth_stages: int = 4

## What item the player receives when harvesting (can be null for decorative plants)
@export var harvest_item_name: String = ""
@export var harvest_amount: int = 1

## Optional: Different models for each growth stage
## Leave empty to use the plant_scene's internal stage system
@export var stage_meshes: Array[Mesh] = []
