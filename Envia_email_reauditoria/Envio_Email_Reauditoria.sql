CREATE OR REPLACE PROCEDURE                           UNMDRC.PRC_ENVIA_EMAIL_REAUDIT_MED_PSICO(vATENDIMENTO NUMBER, 
                                                                                                 vUSUARIO VARCHAR2,
                                                                                                 vPOSRECUSA VARCHAR2,
                                                                                                 vPORORIENTACAOMEDICA VARCHAR2,
                                                                                                 vPORINDICACAOPSICO VARCHAR2,
                                                                                                 vPOSREAVALICACAO VARCHAR2,
                                                                                                 vPSICOLOGO VARCHAR2, 
                                                                                                 vNOME_PSI VARCHAR2,
                                                                                                 vMEDICO VARCHAR2,
                                                                                                 vPSICO_INDIVIDUAL VARCHAR2,
                                                                                                 vPSICO_GRUPO VARCHAR2,
                                                                                                 vPSICO_INDICACAO VARCHAR2,
                                                                                                 vOBS VARCHAR2,
                                                                                                 vMOTIVO VARCHAR2,
                                                                                                 vDATA VARCHAR2) AS
TEXTO VARCHAR2(5000);
TEXTO2 VARCHAR2(200);
vNOMEPACIENTE VARCHAR2(100);
vSOLICITANTE VARCHAR2(100);
vCARTEIRA VARCHAR2(100);
vCODIGO_ATENDIMENTO DBAMV.ATENDIME.CD_aTENDIMENTO%TYPE;
/************************************************************************************
 *  OWNER: UNMDRC                                                                   *
 ************************************************************************************
 *  OBJETO: UNMDRC.PRC_ENVIA_EMAIL_REAUDIT_MED_PSICO                                *
 ************************************************************************************
 *  OBJETIVO DO OBJETO:                                                             *
 *    - Este objeto tem por objetivo disparar email mediante o preenchimento   do   *
 *      documento 1046.                                                              *
 *|--------------------------------------------------------------------------------|*
 *| Data Mod.  | Proprietario            | Dev.              | Versao | Alteracao  |*
 *|------------+-------------------------+------------------+--------+-------------|*
 *| 02/07/2026  | Desenv                 | Gabriel           | 1.0    |            |*
 *|--------------------------------------------------------------------------------|*
 ************************************************************************************/

BEGIN 

        SELECT P.NM_PACIENTE, UNMDRC.FNC_FORMATA_CARTEIRA_UNIMED(A.NR_CARTEIRA), CD_ATENDIMENTO 
          INTO vNOMEPACIENTE, vCARTEIRA, vCODIGO_ATENDIMENTO
          FROM ATENDIME A 
    INNER JOIN PACIENTE P ON A.CD_PACIENTE = P.CD_PACIENTE 
         WHERE A.CD_ATENDIMENTO = vATENDIMENTO;

    BEGIN
            SELECT PR.NM_PRESTADOR 
                   INTO vSOLICITANTE
              FROM PW_DOCUMENTO_CLINICO PDC
        INNER JOIN DOCUMENTO PEC 		 ON PDC.CD_DOCUMENTO_CLINICO = PEC.CD_DOCUMENTO_CLINICO
        INNER JOIN PESSOA P          	 ON P.CD_PACIENTE = PDC.CD_PACIENTE
        INNER JOIN ATENDIME A            ON A.CD_ATENDIMENTO = PDC.CD_ATENDIMENTO
        INNER JOIN COLABORADOR PR		 ON PDC.CD_PRESTADOR = PR.CD_PRESTADOR
             WHERE PDC.CD_OBJETO = 470
               AND PEC.CD_DOCUMENTO = 1046
               AND PDC.TP_STATUS IN ('FECHADO', 'ASSINADO')
               AND PDC.CD_ATENDIMENTO = vATENDIMENTO
             ORDER BY PDC.DH_FECHAMENTO DESC
             FETCH NEXT 1 ROW ONLY;
             EXCEPTION WHEN NO_DATA_FOUND THEN 
                    vSOLICITANTE := '';
    END; 
        
    IF vPOSRECUSA = 'true' THEN
       SELECT 'Avaliação Médico/Consultores - Reauditoria' INTO TEXTO2 FROM DUAL;

       SELECT '<html lang="pt-br">
                <head>
                  <meta charset="iso-8859-1"/>
                </head>
                <body>
                <h2>'||vNOMEPACIENTE||'</h2>
                <p>Carteira Unimed: '||vCARTEIRA||'</p>
                <p>Opção selecionada: Reauditoria após Recusa da Proposta Terapêutica Pelo Paciente/Usuário<br>
                   Data: '||vDATA||'</p>
                <p>'||(SELECT CASE 
                                WHEN vPSICOLOGO = 'true' THEN 'Psicólogo Consultor: '||vNOME_PSI
                                WHEN vMEDICO    = 'true' THEN 'Consultor Médico' END FROM DUAL)||'</p>
                <p>Nova Conduta Sugerida:<br>'||COALESCE((SELECT CASE WHEN vPSICO_INDIVIDUAL = 'true' THEN 'Psicoterapia Individual'
                                                                      WHEN vPSICO_GRUPO      = 'true' THEN 'Psicoterapia de Grupo'
                                                                      WHEN vPSICO_INDICACAO  = 'true' THEN 'Outras Indicações' END FROM DUAL), 'Não nformado')||'</p>
                <p>Motivo da reauditoria:<br>'||COALESCE(vMOTIVO, '')||'</p>
                <p>Observações:<br>'||COALESCE(vOBS, '')||'</p>
                <p>Preenchido por: '||vUSUARIO||'</p>				                                                                                                                                              
                </body>
                </html>'
          INTO TEXTO 
          FROM DUAL;
    END IF;
    
    IF vPORORIENTACAOMEDICA = 'true' THEN
       SELECT 'Avaliação Médico/Consultores - Reauditoria' INTO TEXTO2 FROM DUAL;

       SELECT '<html lang="pt-br">
                <head>
                  <meta charset="iso-8859-1"/>
                </head>
                <body>
                <h2>'||vNOMEPACIENTE||'</h2>
                <p>Carteira Unimed: '||vCARTEIRA||'</p>
                <p>Opção selecionada: Reauditoria por Orientação Médica<br>
                   Data: '||vDATA||'</p>
                <p>'||(SELECT CASE 
                                WHEN vPSICOLOGO = 'true' THEN 'Psicólogo Consultor: '||vNOME_PSI
                                WHEN vMEDICO    = 'true' THEN 'Consultor Médico' END FROM DUAL)||'</p>
                <p>Nova Conduta Sugerida:<br>'||COALESCE((SELECT CASE WHEN vPSICO_INDIVIDUAL = 'true' THEN 'Psicoterapia Individual'
                                                                      WHEN vPSICO_GRUPO      = 'true' THEN 'Psicoterapia de Grupo'
                                                                      WHEN vPSICO_INDICACAO  = 'true' THEN 'Outras Indicações' END FROM DUAL), 'Não nformado')||'</p>
                <p>Motivo da reauditoria:<br>'||COALESCE(vMOTIVO, '')||'</p>
                <p>Observações:<br>'||COALESCE(vOBS, '')||'</p>
                <p>Preenchido por: '||vUSUARIO||'</p>				                                                                                                                                              
                </body>
                </html>'
          INTO TEXTO 
          FROM DUAL;
    END IF;
    
    IF vPORINDICACAOPSICO = 'true' THEN
       SELECT 'Avaliação Médico/Consultores - Reauditoria' INTO TEXTO2 FROM DUAL;

       SELECT '<html lang="pt-br">
                <head>
                <meta charset="iso-8859-1"/>
                </head>
                <body>
                <h2>'||vNOMEPACIENTE||'</h2>
                <p>Carteira Unimed: '||vCARTEIRA||'</p>
                <p>Opção selecionada: Reauditoria por Indicação do Psicólogo<br>
                   Data: '||vDATA||'</p>
                <p>'||(SELECT CASE 
                                WHEN vPSICOLOGO = 'true' THEN 'Psicólogo Consultor: '||vNOME_PSI
                                WHEN vMEDICO    = 'true' THEN 'Consultor Médico' END FROM DUAL)||'</p>
                <p>Nova Conduta Sugerida:<br>'||COALESCE((SELECT CASE WHEN vPSICO_INDIVIDUAL = 'true' THEN 'Psicoterapia Individual'
                                                                      WHEN vPSICO_GRUPO      = 'true' THEN 'Psicoterapia de Grupo'
                                                                      WHEN vPSICO_INDICACAO  = 'true' THEN 'Outras Indicações' END FROM DUAL), 'Não nformado')||'</p>
                <p>Motivo da reauditoria:<br>'||COALESCE(vMOTIVO, '')||'</p>
                <p>Observações:<br>'||COALESCE(vOBS, '')||'</p>
                <p>Preenchido por: '||vUSUARIO||'</p>				                                                                                                                                              
                </body>
                </html>'
          INTO TEXTO 
          FROM DUAL;
    END IF;
    
    IF vPOSREAVALICACAO = 'true' THEN
       SELECT 'Avaliação Médico/Consultores - Reauditoria' INTO TEXTO2 FROM DUAL;

       SELECT '<html lang="pt-br">
                <head>
                  <meta charset="iso-8859-1"/>
                </head>
                <body>
                <h2>'||vNOMEPACIENTE||'</h2>
                <p>Carteira Unimed: '||vCARTEIRA||'</p>
                <p>Opção selecionada: Reauditoria após Reavaliação do Auditor<br>
                   Data: '||vDATA||'</p>
                <p>'||(SELECT CASE 
                                WHEN vPSICOLOGO = 'true' THEN 'Psicólogo Consultor: '||vNOME_PSI
                                WHEN vMEDICO    = 'true' THEN 'Consultor Médico' END FROM DUAL)||'</p>
                <p>Nova Conduta Sugerida:<br>'||COALESCE((SELECT CASE WHEN vPSICO_INDIVIDUAL = 'true' THEN 'Psicoterapia Individual'
                                                                      WHEN vPSICO_GRUPO      = 'true' THEN 'Psicoterapia de Grupo'
                                                                      WHEN vPSICO_INDICACAO  = 'true' THEN 'Outras Indicações' END FROM DUAL), 'Não nformado')||'</p>
                <p>Motivo da reauditoria:<br>'||COALESCE(vMOTIVO, '')||'</p>
                <p>Observações:<br>'||COALESCE(vOBS, '')||'</p>
                <p>Preenchido por: '||vUSUARIO||'</p>				                                                                                                                                              
                </body>
                </html>'
          INTO TEXTO 
          FROM DUAL;
    END IF;
    
    DECLARE
        TYPE CARACTERES IS TABLE OF VARCHAR2(50);
        CARACTERES_ISO CARACTERES;
        CARACTERES_UTF CARACTERES;
    BEGIN   
        CARACTERES_ISO := CARACTERES('&Aacute;','&Eacute;','&Iacute;','&Oacute;','&Uacute;','&aacute;','&eacute;','&iacute;','&oacute;','&uacute;','&Acirc;','&Ecirc;','&Ocirc;',
                                        '&acirc;','&ecirc;','&ocirc;','&Agrave;','&agrave;','&Uuml;','&uuml;','&Ccedil;','&ccedil;','&Atilde;','&Otilde;','&atilde;','&otilde;',
                                        '&Ntilde;','&ntilde;');
        CARACTERES_UTF := CARACTERES('Á','É','Í','Ó','Ú','á','é','í','ó','ú','Â','Ê','Ô','â','ê','ô','À','à','Ü','ü','Ç','ç','Ã','Õ','ã','õ','Ñ','ñ');

        FOR ITEM IN CARACTERES_UTF.FIRST..CARACTERES_UTF.LAST
        LOOP
            TEXTO := REPLACE(TEXTO, CARACTERES_UTF(ITEM), CARACTERES_ISO(ITEM));
            DBMS_OUTPUT.PUT_LINE(TEXTO2);
        END LOOP;
    END;

    UNMDRC.PRC_GRAVAEMAIL(
    'text/html',
    'Documento 1046',
    'MULTI',
    'gabrielalvesrc1234@gmail.com.br',
    'Centro Multi',
    'centromultircc41424@gmail.com.br',
    TEXTO2,
    TEXTO);

END;