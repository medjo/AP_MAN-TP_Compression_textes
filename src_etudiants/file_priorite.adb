with Ada.Integer_Text_Io; use Ada.Integer_Text_Io;
with Ada.Text_Io; use Ada.Text_Io;
with Ada.Unchecked_Deallocation;
with Ada.Streams.Stream_IO;

package body File_Priorite is
	
	type Element is
		record
			Data : Donnee;
			Prio : Priorite;
		end record;
					
	type Table is array (Natural range <>) of Element;
	
	type File_Interne(Taille : Positive) is 
		record
			Tab : Table(1 .. Taille);
            Capacite : Integer := 0;
		end record;
	
	procedure Liberer is new Ada.Unchecked_Deallocation (File_Interne, File_Prio);	
	
	function Cree_File(Capacite: Positive) return File_Prio is
		File : File_Prio := new File_Interne(Capacite);
	begin
		return File;
	end Cree_File;
		
	procedure Libere_File(F : in out File_Prio) is
	begin
		Liberer(F);
	end Libere_File;
	
	function Est_Vide(F: in File_Prio) return Boolean is
	begin
		return (F = NULL or else F.Capacite = 0 );
	end Est_Vide;
	
	function Est_Pleine(F: in File_Prio) return Boolean is
	begin
		if (F.all.Capacite) < (F.all.Tab'Last) then
			return false;
		else
			return true;
		end if;
	end Est_Pleine;
	
	procedure Insere(F : in File_Prio; D : in Donnee; P : in Priorite) is
		E : Element := Element'(Data => D, Prio => P);
		Indice : Integer;
		Tmp : Element;
	begin
		if (NOT(Est_Pleine(F))) then
			F.all.Capacite := F.all.Capacite + 1;
			F.all.Tab(F.Capacite) := E;
			Indice := F.Capacite;
			while (Indice > 1) and then (Est_Prioritaire (F.all.Tab(Indice).Prio, F.all.Tab(Indice / 2).Prio)) loop
				Tmp := F.all.Tab(Indice);
				F.all.Tab(Indice) := F.all.Tab(Indice / 2);
				F.all.Tab(Indice / 2) := Tmp;
				Indice := Indice / 2;
			end loop;
		else
			raise File_Prio_Pleine;
		end if;
	end Insere;
	
	procedure Supprime(F: in File_Prio; D: out Donnee; P: out Priorite) is
		Indice : Integer;
		Tmp : Element;
		Fils_G_Prio : Boolean;
		Fils_D_Prio : Boolean;
		
		--Si l'element à l'indice Fils n'est pas dans le tas
		--		renvoie faux
		--Sinon
		--		renvoie Est_Prioritaire(elem fils, elem pere)
		function Existe_Et_Est_Prio(Fils : in Integer; Pere : in Integer) return Boolean is
		begin
			if (Fils <= F.all.Capacite) then
				return Est_Prioritaire (F.all.Tab(Fils).Prio, F.all.Tab(Pere).Prio);
			else
				return false;
			end if;
		end Existe_Et_Est_Prio;
		
	begin
		if (Est_Vide(F)) then
			raise File_Prio_Vide;
		else 
			D := F.all.Tab(F.all.Tab'First).Data;
			P := F.all.Tab(F.all.Tab'First).Prio;
			F.all.Tab(F.all.Tab'First) := F.all.Tab(F.all.Capacite);
			F.all.Capacite := F.all.Capacite - 1;
			Indice := F.all.Tab'First;
			Fils_G_Prio := Existe_Et_Est_Prio (2 * Indice, Indice);
			Fils_D_Prio := Existe_Et_Est_Prio (2 * Indice + 1, Indice);
			while (Indice <= F.all.Capacite / 2
					AND	(Fils_G_Prio OR Fils_D_Prio))
			loop
				if ((2 * Indice + 1) > F.all.Capacite 
						or Est_Prioritaire (F.all.Tab(2 * Indice).Prio, 
								F.all.Tab(2 * Indice + 1).Prio))
				then
					Tmp := F.all.Tab(Indice);
					F.all.Tab(Indice) := F.all.Tab(Indice * 2);
					F.all.Tab(Indice * 2) := Tmp;
					Indice := Indice * 2;
					Fils_G_Prio := Existe_Et_Est_Prio (2 * Indice, Indice);
					Fils_D_Prio := Existe_Et_Est_Prio (2 * Indice + 1, Indice);
				else 
					Tmp := F.all.Tab(Indice);
					F.all.Tab(Indice) := F.all.Tab(Indice * 2 + 1);
					F.all.Tab(Indice * 2 + 1) := Tmp;
					Indice := Indice * 2 + 1;
					Fils_G_Prio := Existe_Et_Est_Prio (2 * Indice, Indice);
					Fils_D_Prio := Existe_Et_Est_Prio (2 * Indice + 1, Indice);
				end if;
			end loop;
		end if;
	end Supprime;
	
	procedure Prochain(F: in File_Prio; D: out Donnee; P: out Priorite) is 
	begin
		if (Est_Vide(F)) then
			raise File_Prio_Vide;
		else 
			D := F.all.Tab(F.all.Tab'First).Data;
			P := F.all.Tab(F.all.Tab'First).Prio;
		end if;
	end Prochain;
	
    function GetPrio(F : in File_Prio ; Indice : in Positive) return Priorite is
    begin
        return F.Tab(Indice).Prio;
    end GetPrio;

    function GetCapa(F : in File_Prio ) return Integer is
    begin
        return F.Capacite;
    end GetCapa;

    procedure SetData(F : in out File_Prio ; D : Donnee ; I : Natural) is
    begin
        F.all.Tab(I).Data := D;
    end SetData;

    function GetFirst(F : File_Prio) return Natural is
    begin
        return F.Tab'First;
    end GetFirst;

    function GetLast(F : File_Prio) return Natural is
    begin
        return F.Tab'Last;
    end GetLast;
    
    function GetData_File(F : in File_Prio ; I : Natural) return Donnee is
    begin
        return F.Tab(I).Data;
    end GetData_File;

end File_Priorite;
