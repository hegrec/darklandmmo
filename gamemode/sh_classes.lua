
ClassTrees = {}

ClassTrees["Craftsman"] = {}
ClassTrees["Craftsman"]["Craftsman"] = {
	AttributeIncrease = {
		Intelligence = 10
	},
	StatIncrease = {
		Elementalism = 5,
		Mysticism = 5,
		Divinity = 5,
		Alchemy = 5,
		Cooking = 5
	},
	Icon = "darkland/rpg/items/immolate",
	Description = "Description goes here",
	EvolvesTo = {"Mage"},
	EvolveText = "You have successfully proven yourself in the way of the Craftsman! Prepare to become more powerful than ever before!"
	}
	ClassTrees["Craftsman"]["Blacksmith"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Elementalism = 15,
			Divinity = 5
		},
		EvolvesTo = {"Artisan"},
		EvolveText = "You have successfully proven yourself in the way of the Craftsman! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Craftsman"]["Artisan"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Endurance = 5
			},
			StatIncrease = {
				Elementalism = 25,
				Divinity = 5,
				Defence = 10
			},
			EvolvesTo = {"Maestro"},
			EvolveText = "You have successfully proven yourself in the way of the Craftsman! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Craftsman"]["Maestro"] = {
				AttributeIncrease = {
					Intelligence = 5,
					Endurance = 5
				},
				StatIncrease = {
					Divinity = 15,
					Defence = 5
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}


ClassTrees["Fighter"] = {}
ClassTrees["Fighter"]["Fighter"] = {
	AttributeIncrease = {
		Intelligence = 15,
		Endurance = 5
	},
	StatIncrease = {
		Divinity = 30,
		Defence = 10
	},
	EvolvesTo = {"Warrior","Knight","Rogue"},
	EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
	Icon = "darkland/rpg/items/immolate",
	Description = "Description goes here"
	}
	ClassTrees["Fighter"]["Warrior"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Mysticism = 10,
			Elementalism = 5,
			Acrobatics = 5
		},
		EvolvesTo = {"Gladiator","Warlord"},
		EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Fighter"]["Gladiator"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Duelist"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Fighter"]["Duelist"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
		ClassTrees["Fighter"]["Warlord"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Destroyer"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Fighter"]["Destroyer"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
	ClassTrees["Fighter"]["Knight"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Mysticism = 10,
			Elementalism = 5,
			Acrobatics = 5
		},
		EvolvesTo = {"Paladin","Avenger"},
		EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Fighter"]["Paladin"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Champion"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Fighter"]["Champion"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
		ClassTrees["Fighter"]["Avenger"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Vindicator"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Fighter"]["Vindicator"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
	ClassTrees["Fighter"]["Rogue"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Mysticism = 10,
			Elementalism = 5,
			Acrobatics = 5
		},
		EvolvesTo = {"Assassin","Avenger"},
		EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Fighter"]["Assassin"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Guillotine"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Fighter"]["Guillotine"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
		ClassTrees["Fighter"]["Hawkeye"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Sagittarius"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Fighter"]["Sagittarius"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}

ClassTrees["Mystic"] = {}
ClassTrees["Mystic"]["Mystic"] = {
	AttributeIncrease = {
		Intelligence = 15,
		Endurance = 5
	},
	StatIncrease = {
		Divinity = 30,
		Defence = 10
	},
	EvolvesTo = {"Seer","Oracle"},
	EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
	Icon = "darkland/rpg/items/immolate",
	Description = "Description goes here"
	}
	ClassTrees["Mystic"]["Seer"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Mysticism = 10,
			Elementalism = 5,
			Acrobatics = 5
		},
		EvolvesTo = {"Sorcerer","Necromancer"},
		EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Mystic"]["Sorcerer"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Archmage"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Mystic"]["Archmage"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
		ClassTrees["Mystic"]["Necromancer"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Phantom"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Mystic"]["Phantom"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
	ClassTrees["Mystic"]["Oracle"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Mysticism = 10,
			Elementalism = 5,
			Acrobatics = 5
		},
		EvolvesTo = {"Hierophant","Bishop"},
		EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Mystic"]["Hierophant"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Seraph"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Mystic"]["Seraph"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
		ClassTrees["Mystic"]["Bishop"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Patriach"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Mystic"]["Patriach"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
	ClassTrees["Mystic"]["Rogue"] = {
		AttributeIncrease = {
			Intelligence = 5,
			Endurance = 5
		},
		StatIncrease = {
			Mysticism = 10,
			Elementalism = 5,
			Acrobatics = 5
		},
		EvolvesTo = {"Assassin","Avenger"},
		EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
		Icon = "darkland/rpg/items/immolate",
		Description = "Description goes here"
	}
		ClassTrees["Mystic"]["Assassin"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Guillotine"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Mystic"]["Guillotine"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}
		ClassTrees["Mystic"]["Hawkeye"] = {
			AttributeIncrease = {
				Intelligence = 15,
				Agility = 5
			},
			StatIncrease = {
				Mysticism = 25,
				Defence = 5,
				Acrobatics = 10
			},
			EvolvesTo = {"Sagittarius"},
			EvolveText = "You have successfully proven yourself in the way of the Fighter! Prepare to become more powerful than ever before!",
			Icon = "darkland/rpg/items/immolate",
			Description = "Description goes here"
		}
			ClassTrees["Mystic"]["Sagittarius"] = {
				AttributeIncrease = {
					Intelligence = 15,
					Agility = 5
				},
				StatIncrease = {
					Mysticism = 25,
					Defence = 5,
					Acrobatics = 10
				},
				Icon = "darkland/rpg/items/immolate",
				Description = "Description goes here"
			}