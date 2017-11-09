
// purpose of class is the extraction of favicons from a webApp
class faviconExtract : Object {
    string[] FAVICON_STRINGS = {"icon", "shortcut icon", "apple-touch-icon-precomposed", "msapplication-TileImage", "apple-touch-icon", "msapplication-square" }; // all resources names linked to favicons in a HTML document  
    private string _HTML_content;
    private string _URL;
    
    public string HTML_content {
        construct set {
            _HTML_content = value;
        }
        get {
            return _HTML_content;
        }
    }
    
    public string URL {
        construct set {
            _URL = value;
        }
        get {
            return _URL;
        }
    }
    // Spaeter aendern
    private Gee.ArrayList<string> absolute_location;
    
    public faviconExtract (string HTML_content, string URL) {
        Object (HTML_content: HTML_content, URL: URL);
   }
    
    construct {  
        var favicons_location = new Gee.ArrayList<string> ();
        absolute_location = new Gee.ArrayList<string> (); 
        var HTML_content_length = HTML_content.length;
        
        // finds all locations of favicons mentionend in the HTML document
        foreach (string favicon_string in FAVICON_STRINGS){
            var i = 0;
                
            /*
            typical example of favicon location is <link rel="shortcut icon" href="//cdn.sstatic.net/stackoverflow/img/favicon.ico?v=4f32ecc8f43d">
            we will search rel="shortcut icon", then ref and then extract the location
            */
            while (i < HTML_content_length) {
                var favicon_position = HTML_content.index_of ("rel=\"" + favicon_string, i);
                var ref_position = HTML_content.index_of ("href=\"", favicon_position); 
        
                if (favicon_position == -1 || ref_position == -1) {break;} // if we dont find anything its worthless to search with favicon_string
                
                
                // in HTML its very likely that ref=" comes before >. If not, we just ignore it
                if (ref_position < HTML_content.index_of (">", favicon_position)) {
                    var quotation_mark = HTML_content.index_of ("\"", ref_position + 6); // 6 is the length of ref="
                    if (quotation_mark == -1) {break;} 
                    
                    var extracted_url = HTML_content.slice (ref_position + 6, quotation_mark);
                    
                    favicons_location.add (extracted_url);
                }
                i = favicon_position + 1; // + 1 prevents infinitive loop              
            }  
        }
        
        // get rids of webpage so just the root adress is there
        // finishs without a "/"
        var split_results = URL.split("/");
        string splitted = "";
        

        for (int i = 0; i < split_results.length - 1; i++) {
                if (i < split_results.length - 2) {
                    splitted += split_results[i] + "/";
                }
                else  {
                    splitted += split_results[i];
                }
        }
        URL = splitted;
        
        /*
        There are 3 ways of writing a URL 1. absolute 2. relative with backslash in the beginning
        3. relative without backslash
        now we change into absolute URLs
        */
        foreach (string favicon_location in favicons_location) {
            if (favicon_location.has_prefix ("http://") || favicon_location.has_prefix ("https://")) {
                absolute_location.add (favicon_location);
                continue;
            }
            if (favicon_location.has_prefix ("/")) {
                absolute_location.add (URL + favicon_location);
            }
            else {
                absolute_location.add (URL + "/" + favicon_location);
            }
        }
    }
    
    
    public async void download_icons (string temp_folder_location) {
        if (absolute_location.size == 0) {
            return;
        }    
    }
    
}



























