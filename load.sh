while IFS="," read -r skos_file namespace
do
    filename="${skos_file##*/}"
    wget https://raw.githubusercontent.com/viaacode/datamodels/$branch/$skos_file
    import_file $filename $namespace/%s --to sqlite:///meemoo_atramhasis.sqlite --conceptscheme-uri $namespace
    rm $filename
done < /data/data.csv