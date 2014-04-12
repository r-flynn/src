#!/bin/bash
#
#

DITA_OT_PATH="/path/to/my/DITA-OT1.8.4"

PLUGIN_SOURCE_PATH="/path/to/my/bookmaker/src"

PLUGIN_ZIP_PATH="/path/to/my/docbook5-dita-ot-plugin.zip"

PLUGIN_DIR_NAME="${DITA_OT_PATH}/plugins/docbook5-dita-ot-plugin"

TEST_DITA_FILE="/path/to/my/test.ditamap"

OUTPUT_DIR="/path/to/my/bookmaker/output"

pushd ${PLUGIN_SOURCE_PATH}
  ant
popd


if [ -e ${PLUGIN_DIR_NAME} ]
then

  echo ""
  echo "Removing ${PLUGIN_DIR_NAME}"
  echo ""

  rm -rf ${PLUGIN_DIR_NAME}
fi

if [ -e ${OUTPUT_DIR} ]
then

  echo ""
  echo "Removing ${OUTPUT_DIR}"
  echo ""

  rm -rf ${OUTPUT_DIR}
fi

echo ""
echo "Unzipping ${PLUGIN_ZIP_PATH}."
echo ""

unzip ${PLUGIN_ZIP_PATH} -d ${DITA_OT_PATH}/plugins

pushd ${DITA_OT_PATH}


export DITA_HOME="${DITA_OT_PATH}"
export DITA_DIR="${DITA_OT_PATH}"
export PATH="$DITA_DIR/tools/ant/bin:$PATH"
NEW_CLASSPATH="$DITA_DIR/lib:$DITA_DIR/lib/dost.jar:$DITA_DIR/lib/commons-codec-1.4.jar:$DITA_DIR/lib/resolver.jar:$DITA_DIR/lib/icu4j.jar"
NEW_CLASSPATH="${DITA_DIR}/lib/xercesImpl.jar:${DITA_DIR}/lib/xml-apis.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/saxon/saxon9.jar:$DITA_DIR/lib/saxon/saxon9-dom.jar:$NEW_CLASSPATH"
if test -n "$CLASSPATH"
then
export CLASSPATH="$NEW_CLASSPATH":"$CLASSPATH"
else
export CLASSPATH="$NEW_CLASSPATH"
fi

JAVA_HOME="/opt/jdk1.7.0_51"

ant -Dargs.input="${TEST_DITA_FILE}" \
    -Doutput.dir="${OUTPUT_DIR}" \
    -Dtranstype="docbook" \
    -Dargs.xsl="${PLUGIN_DIR_NAME}/xsl/xslt-overrides.xsl" \
    -Ddita.temp.dir="${OUTPUT_DIR}/temp" \
    -Dclean.temp="no"

popd
