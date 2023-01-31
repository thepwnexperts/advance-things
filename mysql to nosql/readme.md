
#use

#

'''python script.py --sql-host hostname --sql-user username --sql-password password --sql-db databasename --mongo-url mongodb+srv://username:password@cluster-url/database --mongo-db mongodatabasename '''

<button onclick="myFunction()">Copy code</button>
<pre>
  <code id="code">
    python script.py --sql-host hostname --sql-user username --sql-password password --sql-db databasename --mongo-url mongodb+srv://username:password@cluster-url/database --mongo-db mongodatabasename 
  </code>
</pre>

<script>
function myFunction() {
  var copyText = document.getElementById("code");
  navigator.clipboard.writeText(copyText.innerText).then(function() {
    alert("Copied to clipboard!");
  }, function(err) {
    console.error("Failed to copy text: ", err);
  });
}
</script>
