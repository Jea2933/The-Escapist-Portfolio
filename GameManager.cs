using Godot;
using System;
//using static PlayerManager;
public partial class GameManager : Node
{
	public static GameManager Instance { get; private set; }


	//public int Player1_currentHealth: int = Player1_maxHealth


	public PackedScene shieldScene;
	public Node2D shieldInstance;
	
	
	
	public bool player1dead = false;
	public bool player2dead = false;
	public bool player3dead = false;

	public bool player1revived = false;
	public bool player2revived = false;
	public bool player3revived = false;

	public int player1health = 3;
	public int player2health = 5;
	public int player3health = 8;

	public int was_on_Player = 0;

	public bool dialogueOver = false;

	public int timesplayer3died = 0;

	public int current_character { get; set; } = 1; //For debug printing 

	public int current_world_index = 1; //Decides what world will be active from local_world_manager

	public int current_player_index = 1; //Decides what player will be active from local_player_manager

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Ready()
	{
		Instance = this;

		var rng = new RandomNumberGenerator();
		rng.Randomize();

		int randomIndex = rng.RandiRange(0, 2);
		current_world_index = randomIndex;
		current_player_index = randomIndex;
		GD.Print($"Random startup: World Index: {current_world_index}, Player Index: {current_player_index}");
		
		shieldScene = GD.Load<PackedScene>("res://Shield.tscn");

		if (shieldScene != null)
		{
			shieldInstance = shieldScene.Instantiate<Node2D>();
			AddChild(shieldInstance);
		}


		shieldInstance.GlobalPosition = new Vector2(170, 100);
		shieldInstance.Visible = false;

		GD.Print("Shield added at: ", ((Node2D)shieldInstance).GlobalPosition);

	}

	public Node GetShield()
	{
		return shieldInstance;
	}


	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("ui_1"))
		{
			current_player_index = 0;
			current_world_index = 0;

			if (current_character != 1)
			{
				current_character = 1;
				GD.Print("Game Manager: On Player 1");
			}
			else 
			{
				GD.Print("Game Manager: Already on Player 1");
			}
		}
		if (Input.IsActionJustPressed("ui_2"))
		{
			current_player_index = 1;
			current_world_index = 1;

			if (current_character != 2)
			{
				current_character = 2;
				GD.Print("Game Manager: On Player 2");
			}
			else
			{
				GD.Print("Game Manager: Already on Player 2");
			}
		}

		if (Input.IsActionJustPressed("ui_3"))
		{
			current_player_index = 2;
			current_world_index = 2;
		}



		if (Input.IsActionJustPressed("ui_cancel"))
		{
			GetTree().Quit();
		}
	}
}
