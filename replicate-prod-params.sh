#!/bin/bash
SRC_REGION="us-east-1"
DST_REGION="us-west-2"
PREFIX="/payrit/prod/"

echo " Starting optimized replication for $PREFIX from $SRC_REGION → $DST_REGION"

for NAME in $(aws ssm describe-parameters \
  --region $SRC_REGION \
  --parameter-filters "Key=Name,Option=BeginsWith,Values=$PREFIX" \
  --query "Parameters[].Name" \
  --output text); do

  echo "→ Checking parameter: $NAME"

  # Get source parameter
  SRC_PARAM=$(aws ssm get-parameter \
    --name "$NAME" \
    --with-decryption \
    --region $SRC_REGION \
    --query "Parameter" \
    --output json)

  SRC_VALUE=$(echo "$SRC_PARAM" | jq -r '.Value')
  SRC_TYPE=$(echo "$SRC_PARAM" | jq -r '.Type')
  SRC_DESC=$(echo "$SRC_PARAM" | jq -r '.Description // "Replicated parameter"')

  # Try to get destination parameter (suppress errors if not exists)
  DST_PARAM=$(aws ssm get-parameter \
    --name "$NAME" \
    --with-decryption \
    --region $DST_REGION \
    --query "Parameter" \
    --output json 2>/dev/null)

  DST_VALUE=$(echo "$DST_PARAM" | jq -r '.Value // empty')

  # Compare values
  if [ "$SRC_VALUE" != "$DST_VALUE" ]; then
    echo "⚡ Detected change → updating $NAME in $DST_REGION"

    aws ssm put-parameter \
      --name "$NAME" \
      --value "$SRC_VALUE" \
      --type "$SRC_TYPE" \
      --description "$SRC_DESC" \
      --overwrite \
      --region $DST_REGION \
      > /dev/null

    echo " Updated: $NAME"
  else
    echo " Skipped (no change detected): $NAME"
  fi

done

echo " Optimized replication completed successfully!"
