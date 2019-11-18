getwd()
setwd("C:/Users/HP/Documents/Termo/MA7")
library(dplyr)
##guardar bmv como csv y cambiar nombre a porcentaje
bmv<-read.csv("bmv.csv",stringsAsFactors = FALSE)
colnames(bmv)[13]<-"VARPORC"
##guardar ma7 economática
ma7_econ<-read.csv("ma7_econ.csv",stringsAsFactors = FALSE)
ma7_econ<-select(ma7_econ,-Tipo.de.Activo,-Bolsa...Fuente,-Activo...Cancelado)
#PARA CAMBIAR NOMBRE COLUMNAS DE ma7_econ
var<-c("Nombre","clase","cod","sector","max52sem","min52sem","cierre_prev","cierre_hoy","max_hoy","min_hoy","ret_hoy","ret_sem","ret_mes","ret_año","ret_ytd","vol","upa","vla","pvl","pu","fecha")
names(ma7_econ)=var


##cambiar "-" a fecha
##SUSTITUIR EN EL CÓDIGO 30/09/2019 por el trimestre más reciente, encerrado entre comillas
ma7_econ$fecha<-str_replace(ma7_econ$fecha,"-","30/09/2019")

#cambiar a numeric columnas
ma7_econ[5:20] <- lapply(ma7_econ[5:20], as.numeric)
#sustituir ceros
ma7_econ[is.na(ma7_econ)] <- 0


##Crear columna serie2 en bmv para obtener más y menos perdedoras
bmv$SERIE2<-bmv$SERIE
bmv$EMISORA2<-bmv$EMISORA
#eliminar * en serie
bmv$SERIE[bmv$SERIE == "*"]<- ""
#Concatenar serie y emisora de información bmv
bmv$EMISORA<-paste0(bmv$EMISORA,bmv$SERIE)

#cambiar nombre en ma7_econ a emisora para que coincida con archivo bmv
colnames(ma7_econ)[ colnames(ma7_econ) == "cod" ] <- "EMISORA"

#combinar las 2 tablas por el código 
ma7<-merge(bmv,ma7_econ,by="EMISORA")
#cambiar sectores
ma7$sector<-str_replace(ma7$sector,"Alimentos y Beb","Alim. y Beb")
ma7$sector<-str_replace(ma7$sector,"Finanzas y Seguros","Fin. y Seguros")
ma7$sector<-str_replace(ma7$sector,"Siderur & Metalur","Sider. & Met.")
ma7$sector<-str_replace(ma7$sector,"Siderur & Metalur","Sider. & Met.")
ma7$sector<-str_replace(ma7$sector,"-","Bancos y Fin.")
ma7$sector<-str_replace(ma7$sector,"Minerales no Met","Min. no Met.")


ma7$Nombre<-str_replace(ma7$Nombre,"America Movil","América Móvil")
ma7$Nombre<-str_replace(ma7$Nombre,"GMexico","GMéxico")
ma7$Nombre<-str_replace(ma7$Nombre,"Wal Mart de Mexico","Wal Mart de México")



#crear m2_mas
ma2_mas<-ma7 %>% arrange(-VARPORC) 
ma2_mas<-ma2_mas[1:5,] %>% select(EMISORA2,SERIE2,ÚLTIMO,VARPORC,ret_mes,ret_ytd)


#m2_menos
ma2_men<-ma7 %>% arrange(VARPORC) 
ma2_men<-ma2_men[1:5,] %>% select(EMISORA2,SERIE2,ÚLTIMO,VARPORC,ret_mes,ret_ytd)

#crear ma7


ma7<-ma7 %>% select (Nombre,EMISORA,sector,max52sem,min52sem,cierre_prev,PPP,max_hoy,min_hoy,VARPORC,ret_sem,ret_mes,ret_año,ret_ytd,vol,upa,vla,pvl,pu,fecha)

write.csv(ma7,file="ma7.csv")
write.table(ma7,file="ma7.txt",sep="\t",quote=FALSE,col.names=FALSE,row.names = FALSE)
