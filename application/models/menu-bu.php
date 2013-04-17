$menu = '<ul id="menu"><li><a href=" '  . base_url() .  ' " >Home</a></li>';

		$item_num = 0;
		foreach ($main->result() as $item) {

			if($item->DrawsFrom != '')
			{
				$menu .= '<li><a href="' . $item->URLSafeTitleDashed . '" class="drop">' . $item->MenuTitle . '</a>';

				if($item_num >= 3)
					$menu .= '<div class="dropdown_5columns align_right">';
				else
					$menu .= '<div class="dropdown_5columns">';
				$menu .= '<div class="col_5"><h2>' . $item->MenuTitle . '</h2></div>';
    			
				if($item->DrawsFrom == 'sections')
					$sub_menu_array = $sections_array;
				else if($item->DrawsFrom == 'categories')
					$sub_menu_array = $category_array;


				$flag =1;
				$count = count($sub_menu_array[$item->SectionID]); //total number of rows
				//echo $count . '<br>';

				$col_complete = ceil($count/3); //We'll have 3 columns

				//echo $col_complete . '<br>';

				foreach($sub_menu_array[$item->SectionID] as $url => $sub_menu)
				{
    				if($flag==1)
						$menu .= '<div class="col_1"><ul class="greybox">';//Start Col 1 of Menu Items


					$menu .= '<li><a href="' . $url . ' ">' . $sub_menu . '</a></li>';

					if($flag == $col_complete)
					{
						$menu .= '</ul></div>'; // If a third of the menu items have been added, close col 1
						$flag = 1;
					}
					else if($flag == $count)
    					$menu .= '</ul></div>';
    				else
						$flag++;
				}

				$menu .= '</div></li>';

			}
			else
				$menu .= '<li><a href="' . $item->URLSafeTitleDashed . '">' . $item->MenuTitle . '</a></li>';

			$item_num++;
		}

		$menu .= '</ul>';

		echo $menu;