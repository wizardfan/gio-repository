**Name:** Fasta Header Manipulation

**Description:**

		Extracts part of the original header or converts to a shorter header
	

**Input files:**
* The Input Fasta File in fasta format: The fasta file needs to change the header

**Parameters:**
* Conditional element: Input name: type
  * 0
  * -1
  * 1
  * 2
  * 3
  * 4
  * 5
  * 6

**Outputs:**
* output in fasta format
* mapping in tabular format

**Details:**


The tool is designed to solve long header in the fasta files by either extracting substring using regular expression or replacing with serial number. All parts matching the chosen regular expression will be joined by ";" to form the new header. If no match found, the new header will be empty. Therefore when it is hard to find one regular expression for all sequences, the replacing option is recommended which will generate new header in the format of user_defined_prefix_serial number.

**Up to first space or tab**
>sp|P04058-2|ACES_TORCA Isoform T of Acetylcholinesterase OS=Torpedo californica GN=ache ==> >sp|P04058-2|ACES_TORCA

**NCBI gi accession**
>gi|178344|gb|AAA98797.1| albumin [Homo sapiens] ==> >gi|178344

**Uniprot accession**
>sp|P12821|ACE_HUMAN ==> >P12821

**Up to first |**
>P12821|ACE_HUMAN ==> >P12821

**IPI accession**
>IPI:IPI00000005.1|SWISS-PROT:P01111 ==> >IPI:IPI00000005

**Replace with serial number**			
By using the default prefix value gio, the new header will be gio_1, gio_2 ,...

	
