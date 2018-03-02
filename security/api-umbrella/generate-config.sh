echo "generating config file"

cp api-umbrella.yml.template api-umbrella.yml

prop_replace () {
  target_file=${3:-"api-umbrella.yml"}
  echo 'replacing target file ' ${target_file}
  echo 'replace' $1 'with' $2
  sed -i.bak "s/$1/$2/g"  ${target_file}
}

prop_replace 'mongodb_url' "${MONGO_REPLICATE_SET_IPS}"
prop_replace 'rs_name' "${REPLICASET_NAME}"
